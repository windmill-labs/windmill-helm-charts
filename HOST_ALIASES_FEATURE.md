# Windmill Helm Chart - Host Aliases Support

## Overview

This feature adds hostAliases support to Windmill Helm chart, allowing you to configure custom host-to-IP mappings for pods. This is particularly useful for accessing internal services, resolving DNS issues, or working around domain redirection problems.

## Features

- **Global hostAliases**: Configure host aliases that apply to all pods by default
- **Component-specific hostAliases**: Override global settings for specific components (app, worker groups)
- **Flexible configuration**: Each worker group can have its own hostAliases configuration
- **Conditional rendering**: Only renders hostAliases when needed

## Configuration

### Global Configuration

Add hostAliases to the global windmill configuration:

```yaml
windmill:
  hostAliases:
    - ip: "10.0.0.100"
      hostnames:
        - "gitlab-private.company.com"
        - "nexus.company.com"
    - ip: "10.0.0.101"
      hostnames:
        - "harbor.company.com"
```

### App-specific Configuration

Configure hostAliases specifically for the Windmill app:

```yaml
windmill:
  app:
    hostAliases:
      - ip: "10.0.0.102"
        hostnames:
          - "auth-service.internal"
          - "api-gateway.internal"
```

### Worker Group Configuration

Configure hostAliases for specific worker groups:

```yaml
windmill:
  workerGroups:
    - name: "default"
      hostAliases:
        - ip: "10.0.0.103"
          hostnames:
            - "python-registry.internal"
      replicas: 3
    
    - name: "native"
      # Uses global hostAliases if not specified
      replicas: 1
```

## Priority Order

The configuration follows this priority order:

1. **Component-specific** (highest priority): `windmill.app.hostAliases` or `workerGroups[].hostAliases`
2. **Global** (fallback): `windmill.hostAliases`

## Use Cases

### 1. Resolving GitLab Domain Redirection Issues

```yaml
windmill:
  hostAliases:
    - ip: "10.0.0.104"
      hostnames:
        - "gitlab-private.company.com"
        - "gitlab-redirect.company.com"  # Handle redirects
```

### 2. Accessing Internal Package Registries

```yaml
windmill:
  workerGroups:
    - name: "python-workers"
      hostAliases:
        - ip: "10.0.0.105"
          hostnames:
            - "pypi-mirror.internal"
            - "npm-registry.internal"
```

### 3. Development Environment Configuration

```yaml
windmill:
  hostAliases:
    - ip: "10.0.0.106"
      hostnames:
        - "dev-database.local"
        - "dev-cache.local"
        - "dev-storage.local"
```

## Verification

After deployment, you can verify the hostAliases configuration:

```bash
# Check /etc/hosts in a pod
kubectl exec -it windmill-workers-default-xxx -- cat /etc/hosts

# Test domain resolution
kubectl exec -it windmill-workers-default-xxx -- nslookup your-domain.internal
```

## Template Implementation

### worker-groups.yaml
```yaml
{{- if or $.Values.windmill.hostAliases $v.hostAliases }}
hostAliases:
{{- if $v.hostAliases }}
{{- toYaml $v.hostAliases | nindent 8 }}
{{- else }}
{{- toYaml $.Values.windmill.hostAliases | nindent 8 }}
{{- end }}
{{- end }}
```

### app.yaml
```yaml
{{- if or .Values.windmill.hostAliases .Values.windmill.app.hostAliases }}
hostAliases:
{{- if .Values.windmill.app.hostAliases }}
{{- toYaml .Values.windmill.app.hostAliases | nindent 8 }}
{{- else }}
{{- toYaml .Values.windmill.hostAliases | nindent 8 }}
{{- end }}
{{- end }}
```

## Backward Compatibility

This feature is fully backward compatible. Existing configurations will continue to work without any changes, as all hostAliases configurations default to empty arrays.

## Contributing

This feature was added to support various networking scenarios commonly encountered in enterprise environments. If you have suggestions for improvements or encounter issues, please open an issue or submit a pull request. 