# Windmill IaC Operator - Implementation Notes

This document provides implementation guidance for embedding a Kubernetes operator/controller into the Windmill binary to support Infrastructure as Code (IaC) workflows.

## Overview

The goal is to allow users to define Windmill resources (scripts, flows, variables, resources, schedules, etc.) declaratively in Kubernetes YAML and have them automatically synced to the PostgreSQL database. This eliminates the need for a separate operator container while leveraging the existing Windmill binary.

## Architecture Decision

**Chosen Approach: Embedded Controller with `MODE=iac-controller`**

The Windmill binary will support a new mode that runs a Kubernetes controller watching for Custom Resources (CRs) and syncing them to the database.

```
┌─────────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster                          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐  │
│  │ WindmillScript│    │ WindmillFlow │    │ WindmillVariable │  │
│  │     (CR)      │    │     (CR)     │    │      (CR)        │  │
│  └──────┬───────┘    └──────┬───────┘    └────────┬─────────┘  │
│         │                   │                     │             │
│         └───────────────────┼─────────────────────┘             │
│                             │ watch                             │
│                             ▼                                   │
│                    ┌────────────────┐                           │
│                    │   Windmill     │                           │
│                    │ MODE=iac-ctrl  │                           │
│                    └───────┬────────┘                           │
│                            │ direct DB write                    │
└────────────────────────────┼────────────────────────────────────┘
                             ▼
                    ┌────────────────┐
                    │   PostgreSQL   │
                    │   (source of   │
                    │    truth)      │
                    └────────────────┘
```

### Why This Approach

1. **Existing pattern**: Windmill already uses `MODE` env var for server/worker/indexer/mcp
2. **Direct DB access**: No API overhead; controller writes directly to PostgreSQL
3. **Optional**: Users who want IaC add one deployment with `MODE=iac-controller`
4. **Single binary**: No separate operator image to maintain

## Implementation Steps

### 1. Add Kubernetes Client Dependency

Add `kube-rs` crate for Kubernetes API interaction:

```toml
# Cargo.toml
[dependencies]
kube = { version = "0.87", features = ["runtime", "derive"] }
k8s-openapi = { version = "0.20", features = ["v1_28"] }
```

**Note**: Consider making this an optional feature to avoid bloating the binary for non-K8s users:

```toml
[features]
default = []
k8s-operator = ["kube", "k8s-openapi"]
```

### 2. Define Rust Structs for CRDs

Create structs that match the CRD schemas in `crds.yaml`:

```rust
// src/iac/crds.rs

use kube::CustomResource;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(CustomResource, Debug, Clone, Deserialize, Serialize, JsonSchema)]
#[kube(
    group = "windmill.dev",
    version = "v1alpha1",
    kind = "WindmillScript",
    namespaced,
    status = "WindmillScriptStatus",
    shortname = "wscript",
    shortname = "ws"
)]
pub struct WindmillScriptSpec {
    pub workspace: Option<String>,
    pub path: String,
    pub summary: Option<String>,
    pub description: Option<String>,
    pub language: ScriptLanguage,
    pub content: String,
    pub schema: Option<serde_json::Value>,
    pub lock: Option<String>,
    pub kind: Option<ScriptKind>,
    pub tag: Option<String>,
    pub concurrency_limit: Option<i32>,
    pub concurrency_time_window_s: Option<i32>,
    pub cache_seconds: Option<i32>,
    pub dedicated_worker: Option<bool>,
    pub ws_error_handler_muted: Option<bool>,
    pub priority: Option<i32>,
    pub timeout: Option<i32>,
    pub delete_after_use: Option<bool>,
    pub envs: Option<Vec<String>>,
}

#[derive(Debug, Clone, Deserialize, Serialize, JsonSchema)]
pub struct WindmillScriptStatus {
    pub synced_at: Option<String>,
    pub hash: Option<String>,
    pub state: SyncState,
    pub message: Option<String>,
    pub last_modified_in_db: Option<String>,
}

#[derive(Debug, Clone, Deserialize, Serialize, JsonSchema)]
pub enum SyncState {
    Synced,
    OutOfSync,
    Error,
    Conflict,
}

#[derive(Debug, Clone, Deserialize, Serialize, JsonSchema)]
#[serde(rename_all = "lowercase")]
pub enum ScriptLanguage {
    Python3,
    Deno,
    Go,
    Bash,
    Powershell,
    Postgresql,
    Mysql,
    Bigquery,
    Snowflake,
    Mssql,
    Graphql,
    Nativets,
    Bun,
    Php,
    Rust,
    Ansible,
}

// Similar structs for WindmillFlow, WindmillVariable, WindmillResource, etc.
```

### 3. Implement the Controller Loop

```rust
// src/iac/controller.rs

use futures::StreamExt;
use kube::{
    api::{Api, ListParams, Patch, PatchParams},
    runtime::controller::{Action, Controller},
    Client, Resource,
};
use std::sync::Arc;
use tokio::time::Duration;

use crate::db::DB;
use super::crds::{WindmillScript, WindmillScriptStatus, SyncState};

pub struct Context {
    pub db: DB,
    pub client: Client,
    pub namespace_to_workspace: NamespaceMapping,
    pub conflict_policy: ConflictPolicy,
}

#[derive(Clone)]
pub enum ConflictPolicy {
    CrdWins,       // CRD always overwrites DB
    DbWins,        // DB changes prevent CRD sync (mark as Conflict)
    LastWriteWins, // Compare timestamps, most recent wins
}

#[derive(Clone)]
pub enum NamespaceMapping {
    Fixed(String),                    // All CRs go to one workspace
    NamespaceAsWorkspace,             // K8s namespace = Windmill workspace
    Custom(HashMap<String, String>),  // Explicit mapping
}

pub async fn run_controller(ctx: Arc<Context>) -> Result<(), Error> {
    let client = ctx.client.clone();

    // Watch all namespaces or specific ones based on config
    let scripts: Api<WindmillScript> = Api::all(client.clone());

    Controller::new(scripts, ListParams::default())
        .run(reconcile_script, error_policy, ctx)
        .for_each(|res| async move {
            match res {
                Ok(o) => tracing::info!("reconciled {:?}", o),
                Err(e) => tracing::warn!("reconcile failed: {:?}", e),
            }
        })
        .await;

    Ok(())
}

async fn reconcile_script(
    script: Arc<WindmillScript>,
    ctx: Arc<Context>,
) -> Result<Action, Error> {
    let name = script.name_any();
    let namespace = script.namespace().unwrap_or_default();
    let spec = &script.spec;

    // Determine target workspace
    let workspace = spec.workspace.clone().unwrap_or_else(|| {
        match &ctx.namespace_to_workspace {
            NamespaceMapping::Fixed(ws) => ws.clone(),
            NamespaceMapping::NamespaceAsWorkspace => namespace.clone(),
            NamespaceMapping::Custom(map) => {
                map.get(&namespace).cloned().unwrap_or_else(|| "default".to_string())
            }
        }
    });

    // Check current state in DB
    let existing = sqlx::query_as!(
        ScriptRecord,
        "SELECT hash, edited_at FROM script WHERE path = $1 AND workspace_id = $2",
        spec.path,
        workspace
    )
    .fetch_optional(&ctx.db)
    .await?;

    // Compute hash of CRD content
    let crd_hash = compute_hash(&spec.content);

    // Handle conflict detection
    if let Some(ref existing) = existing {
        if existing.hash != crd_hash {
            match ctx.conflict_policy {
                ConflictPolicy::DbWins => {
                    // Check if DB was modified after last sync
                    if let Some(status) = &script.status {
                        if let Some(synced_at) = &status.synced_at {
                            let synced_time = parse_datetime(synced_at)?;
                            if existing.edited_at > synced_time {
                                // DB was modified externally, mark as conflict
                                update_status(&ctx, &script, SyncState::Conflict,
                                    Some("DB modified externally since last sync")).await?;
                                return Ok(Action::requeue(Duration::from_secs(60)));
                            }
                        }
                    }
                }
                ConflictPolicy::LastWriteWins => {
                    // Compare timestamps - implementation depends on tracking CRD update time
                }
                ConflictPolicy::CrdWins => {
                    // Always proceed with sync
                }
            }
        }
    }

    // Sync to database
    let result = sync_script_to_db(&ctx.db, &workspace, spec).await;

    match result {
        Ok(new_hash) => {
            update_status(&ctx, &script, SyncState::Synced, None).await?;
            Ok(Action::requeue(Duration::from_secs(300))) // Re-check every 5 min
        }
        Err(e) => {
            update_status(&ctx, &script, SyncState::Error, Some(&e.to_string())).await?;
            Ok(Action::requeue(Duration::from_secs(30))) // Retry sooner on error
        }
    }
}

async fn sync_script_to_db(
    db: &DB,
    workspace: &str,
    spec: &WindmillScriptSpec,
) -> Result<String, Error> {
    let hash = compute_hash(&spec.content);

    // Use existing Windmill DB functions/queries
    // This should mirror what the API does when creating/updating a script

    sqlx::query!(
        r#"
        INSERT INTO script (
            workspace_id, hash, path, summary, description,
            content, language, lock, schema, kind, tag,
            concurrent_limit, concurrency_time_window_s,
            cache_ttl, dedicated_worker, ws_error_handler_muted,
            priority, timeout, delete_after_use, envs,
            created_by, edited_at
        ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11,
            $12, $13, $14, $15, $16, $17, $18, $19, $20,
            'iac-controller', NOW()
        )
        ON CONFLICT (workspace_id, hash) DO UPDATE SET
            summary = EXCLUDED.summary,
            description = EXCLUDED.description,
            content = EXCLUDED.content,
            -- ... other fields
            edited_at = NOW()
        "#,
        workspace,
        hash,
        spec.path,
        spec.summary,
        spec.description,
        spec.content,
        spec.language.to_string(),
        spec.lock,
        spec.schema,
        spec.kind.as_ref().map(|k| k.to_string()),
        spec.tag,
        spec.concurrency_limit,
        spec.concurrency_time_window_s,
        spec.cache_seconds,
        spec.dedicated_worker,
        spec.ws_error_handler_muted,
        spec.priority,
        spec.timeout,
        spec.delete_after_use,
        spec.envs.as_ref().map(|e| e.as_slice()),
    )
    .execute(db)
    .await?;

    // Also update the script path -> hash mapping
    // (Windmill tracks "current" version separately)

    Ok(hash)
}

fn error_policy(
    _script: Arc<WindmillScript>,
    error: &Error,
    _ctx: Arc<Context>,
) -> Action {
    tracing::error!("reconcile error: {:?}", error);
    Action::requeue(Duration::from_secs(60))
}
```

### 4. Add MODE=iac-controller Entry Point

```rust
// src/main.rs or src/bin/windmill.rs

async fn main() {
    let mode = std::env::var("MODE").unwrap_or_else(|_| "server".to_string());

    match mode.as_str() {
        "server" => run_server().await,
        "worker" => run_worker().await,
        "indexer" => run_indexer().await,
        "mcp" => run_mcp().await,
        "iac-controller" => run_iac_controller().await,  // NEW
        _ => panic!("Unknown mode: {}", mode),
    }
}

async fn run_iac_controller() {
    // Initialize database connection (reuse existing logic)
    let db = init_db().await;

    // Initialize Kubernetes client
    let client = Client::try_default().await
        .expect("Failed to create K8s client. Is KUBECONFIG set or running in-cluster?");

    // Read configuration from env vars
    let conflict_policy = match std::env::var("IAC_CONFLICT_POLICY")
        .unwrap_or_else(|_| "crd-wins".to_string())
        .as_str()
    {
        "crd-wins" => ConflictPolicy::CrdWins,
        "db-wins" => ConflictPolicy::DbWins,
        "last-write-wins" => ConflictPolicy::LastWriteWins,
        other => panic!("Unknown conflict policy: {}", other),
    };

    let namespace_mapping = match std::env::var("IAC_NAMESPACE_MAPPING")
        .unwrap_or_else(|_| "namespace-as-workspace".to_string())
        .as_str()
    {
        "namespace-as-workspace" => NamespaceMapping::NamespaceAsWorkspace,
        fixed if fixed.starts_with("fixed:") => {
            NamespaceMapping::Fixed(fixed.strip_prefix("fixed:").unwrap().to_string())
        }
        _ => NamespaceMapping::NamespaceAsWorkspace,
    };

    let ctx = Arc::new(Context {
        db,
        client,
        namespace_to_workspace: namespace_mapping,
        conflict_policy,
    });

    // Run controllers for all resource types concurrently
    tokio::try_join!(
        iac::controller::run_script_controller(ctx.clone()),
        iac::controller::run_flow_controller(ctx.clone()),
        iac::controller::run_variable_controller(ctx.clone()),
        iac::controller::run_resource_controller(ctx.clone()),
        iac::controller::run_schedule_controller(ctx.clone()),
        iac::controller::run_folder_controller(ctx.clone()),
        iac::controller::run_group_controller(ctx.clone()),
        iac::controller::run_app_controller(ctx.clone()),
        iac::controller::run_workspace_controller(ctx.clone()),
    ).expect("Controller failed");
}
```

### 5. Handle Secrets Securely

For `WindmillVariable` and `WindmillResource` with `valueFrom.secretKeyRef`:

```rust
async fn resolve_value_from_secret(
    client: &Client,
    namespace: &str,
    secret_ref: &SecretKeyRef,
) -> Result<String, Error> {
    let secrets: Api<Secret> = Api::namespaced(client.clone(), namespace);
    let secret = secrets.get(&secret_ref.name).await?;

    let data = secret.data.ok_or(Error::SecretEmpty)?;
    let value = data.get(&secret_ref.key).ok_or(Error::SecretKeyMissing)?;

    let decoded = String::from_utf8(value.0.clone())?;
    Ok(decoded)
}

async fn sync_variable_to_db(
    ctx: &Context,
    namespace: &str,
    workspace: &str,
    spec: &WindmillVariableSpec,
) -> Result<(), Error> {
    // Resolve value from either direct value or secret reference
    let value = if let Some(ref value_from) = spec.value_from {
        if let Some(ref secret_ref) = value_from.secret_key_ref {
            resolve_value_from_secret(&ctx.client, namespace, secret_ref).await?
        } else {
            return Err(Error::InvalidValueFrom);
        }
    } else {
        spec.value.clone().unwrap_or_default()
    };

    // If is_secret, encrypt before storing (use Windmill's existing encryption)
    let stored_value = if spec.is_secret.unwrap_or(false) {
        encrypt_variable(&value)?  // Use existing Windmill encryption
    } else {
        value
    };

    // Insert/update in DB
    sqlx::query!(
        r#"
        INSERT INTO variable (workspace_id, path, value, is_secret, description, account, is_oauth)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        ON CONFLICT (workspace_id, path) DO UPDATE SET
            value = EXCLUDED.value,
            is_secret = EXCLUDED.is_secret,
            description = EXCLUDED.description
        "#,
        workspace,
        spec.path,
        stored_value,
        spec.is_secret.unwrap_or(false),
        spec.description,
        spec.account_id,
        spec.is_oauth.unwrap_or(false),
    )
    .execute(&ctx.db)
    .await?;

    Ok(())
}
```

### 6. Deletion Handling

When a CR is deleted, decide what to do with the DB record:

```rust
// Add finalizer to track deletions
const FINALIZER: &str = "windmill.dev/iac-controller";

async fn reconcile_script(
    script: Arc<WindmillScript>,
    ctx: Arc<Context>,
) -> Result<Action, Error> {
    let deletion_policy = std::env::var("IAC_DELETION_POLICY")
        .unwrap_or_else(|_| "soft-delete".to_string());

    // Check if being deleted
    if script.meta().deletion_timestamp.is_some() {
        // CR is being deleted
        match deletion_policy.as_str() {
            "delete" => {
                // Actually delete from DB
                delete_script_from_db(&ctx.db, &workspace, &spec.path).await?;
            }
            "soft-delete" => {
                // Mark as archived/deleted but keep in DB
                archive_script_in_db(&ctx.db, &workspace, &spec.path).await?;
            }
            "ignore" => {
                // Do nothing, leave DB record
            }
            _ => {}
        }

        // Remove our finalizer to allow K8s to complete deletion
        remove_finalizer(&ctx.client, &script).await?;
        return Ok(Action::await_change());
    }

    // Ensure finalizer is present
    if !script.finalizers().iter().any(|f| f == FINALIZER) {
        add_finalizer(&ctx.client, &script).await?;
    }

    // ... rest of reconciliation
}
```

## Configuration Options

### Environment Variables for iac-controller Mode

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | (required) | PostgreSQL connection string |
| `IAC_CONFLICT_POLICY` | `crd-wins` | How to handle DB/CRD conflicts: `crd-wins`, `db-wins`, `last-write-wins` |
| `IAC_NAMESPACE_MAPPING` | `namespace-as-workspace` | How to map K8s namespaces to workspaces: `namespace-as-workspace`, `fixed:<workspace>` |
| `IAC_DELETION_POLICY` | `soft-delete` | What to do when CR deleted: `delete`, `soft-delete`, `ignore` |
| `IAC_WATCH_NAMESPACES` | (all) | Comma-separated list of namespaces to watch |
| `IAC_RESYNC_INTERVAL` | `300` | Seconds between full resync |
| `IAC_METRICS_PORT` | `8001` | Port for Prometheus metrics |

## Helm Chart Updates

Add new deployment option to values.yaml:

```yaml
# values.yaml additions

iacController:
  enabled: false
  replicas: 1  # Usually 1, uses leader election

  conflictPolicy: "crd-wins"  # crd-wins | db-wins | last-write-wins
  namespaceMapping: "namespace-as-workspace"  # or "fixed:default"
  deletionPolicy: "soft-delete"  # delete | soft-delete | ignore
  watchNamespaces: []  # empty = all namespaces

  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

New template `templates/iac-controller-deployment.yaml`:

```yaml
{{- if .Values.iacController.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: windmill-iac-controller
spec:
  replicas: {{ .Values.iacController.replicas }}
  selector:
    matchLabels:
      app: windmill-iac-controller
  template:
    spec:
      serviceAccountName: windmill-iac-controller
      containers:
        - name: iac-controller
          image: {{ .Values.windmill.image }}:{{ .Values.windmill.tag }}
          env:
            - name: MODE
              value: "iac-controller"
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.windmill.databaseUrlSecretName | default "windmill-secret" }}
                  key: {{ .Values.windmill.databaseUrlSecretKey | default "url" }}
            - name: IAC_CONFLICT_POLICY
              value: {{ .Values.iacController.conflictPolicy }}
            - name: IAC_NAMESPACE_MAPPING
              value: {{ .Values.iacController.namespaceMapping }}
            - name: IAC_DELETION_POLICY
              value: {{ .Values.iacController.deletionPolicy }}
{{- end }}
```

RBAC for the controller `templates/iac-controller-rbac.yaml`:

```yaml
{{- if .Values.iacController.enabled }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: windmill-iac-controller
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: windmill-iac-controller
rules:
  - apiGroups: ["windmill.dev"]
    resources: ["*"]
    verbs: ["get", "list", "watch", "update", "patch"]
  - apiGroups: ["windmill.dev"]
    resources: ["*/status"]
    verbs: ["update", "patch"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list", "watch"]  # For valueFrom.secretKeyRef
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["get", "create", "update"]  # For leader election
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: windmill-iac-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: windmill-iac-controller
subjects:
  - kind: ServiceAccount
    name: windmill-iac-controller
    namespace: {{ .Release.Namespace }}
{{- end }}
```

## Database Schema Considerations

The controller writes directly to existing Windmill tables. Key tables:

- `script` - Scripts with versions (hash-based)
- `flow` - Flows
- `variable` - Variables (including secrets)
- `resource` - Resources
- `resource_type` - Custom resource types
- `schedule` - Schedules
- `folder` - Folders
- `group_` - Groups
- `workspace` - Workspaces
- `workspace_settings` - Workspace settings

### Audit Trail

Consider adding `created_by` / `edited_by` tracking:

```sql
-- When IaC controller creates/updates, set:
created_by = 'iac-controller'
-- Or more detailed:
created_by = 'iac-controller:namespace/resourcename'
```

This allows distinguishing IaC-managed resources from UI/API-created ones.

## Testing Strategy

1. **Unit tests**: Mock Kubernetes client and DB
2. **Integration tests**: Use `k3d` or `kind` with test CRDs
3. **E2E tests**: Full Windmill + PostgreSQL + CRDs

Example test:

```rust
#[tokio::test]
async fn test_script_sync() {
    let db = setup_test_db().await;
    let k8s = setup_mock_k8s();

    // Create a WindmillScript CR
    let script = WindmillScript {
        metadata: ObjectMeta {
            name: Some("test-script".to_string()),
            namespace: Some("default".to_string()),
            ..Default::default()
        },
        spec: WindmillScriptSpec {
            path: "f/test/myscript".to_string(),
            language: ScriptLanguage::Python3,
            content: "def main(): return 42".to_string(),
            ..Default::default()
        },
        status: None,
    };

    // Run reconciliation
    let ctx = Arc::new(Context { db, client: k8s, .. });
    reconcile_script(Arc::new(script), ctx).await.unwrap();

    // Verify DB state
    let result = sqlx::query!("SELECT * FROM script WHERE path = 'f/test/myscript'")
        .fetch_one(&db)
        .await
        .unwrap();

    assert_eq!(result.content, "def main(): return 42");
}
```

## Migration Path

For users with existing Windmill resources who want to adopt IaC:

1. **Export existing resources**: Add a CLI command or script to export DB resources as CRD YAML
2. **Import with skip-existing**: Controller can have a mode to not overwrite existing DB records
3. **Gradual adoption**: Users can start with new resources only, gradually bringing existing ones under IaC control

## Open Questions for Implementation

1. **Version history**: Should CRD updates create new script versions (new hash) or update in place?
2. **Draft vs deployed**: Scripts in Windmill have draft/deployed states - how to represent in CRD?
3. **Permissions**: Should folder/group permissions be syncable via IaC?
4. **Two-way sync**: Should DB changes update CRD status, or even the CRD spec itself?
5. **Webhooks**: Consider admission webhooks for validation before CR creation

## Example Usage

Once implemented, users can do:

```bash
# Install CRDs
kubectl apply -f https://raw.githubusercontent.com/windmill-labs/windmill-helm-charts/main/crds/

# Enable IaC controller in Helm
helm upgrade windmill windmill/windmill --set iacController.enabled=true

# Create a script
cat <<EOF | kubectl apply -f -
apiVersion: windmill.dev/v1alpha1
kind: WindmillScript
metadata:
  name: hello-world
  namespace: default
spec:
  path: f/examples/hello_world
  language: python3
  summary: A simple hello world script
  content: |
    def main(name: str = "World"):
        return f"Hello, {name}!"
EOF

# Check sync status
kubectl get windmillscripts
# NAME          PATH                    LANGUAGE   STATE    SYNCED
# hello-world   f/examples/hello_world  python3    Synced   2024-01-15T10:30:00Z
```
