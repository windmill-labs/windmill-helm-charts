<h1 align="center">
  <img src="https://media.licdn.com/dms/image/D4E0BAQFh9M8zrNFjQw/company-logo_200_200/0/1665352677142?e=2147483647&v=beta&t=iI4YPPusisIuK3I-VjYnt7WVuIA4jsSQpglIwfr9X2U" alt="windmill" width="100">
</h1>

<h4 align="center">Turn scripts into workflows and UIs in minutes</h4>

<p align="center">
<img src="https://github.com/windmill-labs/windmill-helm-charts/actions/workflows/helm_test.yml/badge.svg" alt="drawing"/>
<img src="https://github.com/windmill-labs/windmill-helm-charts/actions/workflows/release.yml/badge.svg" alt="drawing"/>
<img src="https://img.shields.io/github/v/release/windmill-labs/windmill-helm-charts" alt="drawing"/>
<img src="https://img.shields.io/github/downloads/windmill-labs/windmill-helm-charts/total.svg" alt="drawing"/>
</p>

<p align="center">
  <a href="#install">Install</a> •
  <a href="#core-values">Core Values</a> •
  <a href="#full-values">Full Values</a> •
  <a href="#local-s3">Local S3</a> •
  <a href="#caveats">Caveats</a> •  
  <a href="#kubernetes-hosting-tips">Kubernetes Tips</a>
</p>

<hr>

## Install

> Have Helm 3 [installed](https://helm.sh/docs/intro/install).

```sh
helm repo add windmill https://windmill-labs.github.io/windmill-helm-charts/
helm install mywindmill windmill/windmill -n windmill --create-namespace --values values.yaml
```

To update versions:

```
helm repo update windmill
helm upgrade mywindmill windmill/windmill -n windmill --values values.yaml
```

You do not need to provide a values.yaml to be able to test it on minikube.
Follow the steps below.

> **⚠️ Note:**  
> The 3.X release introduces a breaking change due to the migration of the demo PostgreSQL and demo MinIO from Bitnami subcharts to the vanilla MinIO subchart and vanilla non-persistent PostgreSQL pods.  
> These demo services are intended **only for testing or demo purposes** and should **not** be used in production environments under any circumstances and are not made persistent

> The 4.x make workers run with privileged secure context by default and  use UNSHARE_PID by default (https://www.windmill.dev/docs/advanced/security_isolation#pid-namespace-isolation-recommended-for-production). The privileged secure context allow to override cgroup v2 behavior to disable oom.group so that jobs can be killed without killing the entire container. By default cgroup v2 on k8s 1.32+ uses oom.group=1 which result in killing the whole worker instead of the job whenever the job exceed memory. In most cases, that would be the proper behavior but not for Windmill which has proper oom_adj_score priority and handle oom kill on jobs gracefully.


### Postgres instance

The default helm charts enable a postgresql database by default. It should only be used for **demo** or **testing** purposes. It's not persistent, you should use a managed database instance like RDS or have experience managing a real postgres setup on Kubernetes and point the databaseUrl to that.

### When using a non super-user role for postgresql in databaseUrl

You will need to setup some required roles which would otherwise be done
automatically when using a super-user role for the databaseUrl.

Follow those
[instructions](https://docs.windmill.dev/docs/advanced/self_host#run-windmill-without-using-a-postgres-superuser)

### Running windmill pods as non-root user

By default the windmill pods run as `root`. You can opt to run the pods as
non-root by setting uid: 1000

```
windmill
  app
    podSecurityContext:
      runAsUser: 1000
      runAsNonRoot: true
```

### Test it on minikube

To make it work on a local minkube to test. Get the ip address of the ingress:

```
▶ kubectl get ingress -n windmill
NAME       CLASS    HOSTS                        ADDRESS        PORTS   AGE
windmill   <none>   windmill,windmill,windmill   192.168.49.2   80      13m
```

If no ip address displayed, enable the ingress addon:

```
minikube addons enable ingress
```

Then modify /etc/hosts to match the `baseDomain`, by default 'windmill'.

E.g:

```
192.168.49.2   windmill
```

Then open your browser at <http://windmill>

Even if you setup oauth, login as** admin@windmill.dev **/ changeme to setup the
instance & accounts and give yourself admin privileges.

## Core Values

```yaml
# windmill root values block
windmill:
  # domain as shown in browser, this is used together with `baseProtocol` as part of the BASE_URL environment variable in app and worker container and in the ingress resource, if enabled
  baseDomain: windmill
  # secondary domain that duplicates all ingress routes from baseDomain (useful for multiple domains pointing to same services)
  secondaryBaseDomain: ""
  baseProtocol: http
  # postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in app and worker container
  databaseUrl: postgres://postgres:windmill@windmill-postgresql/windmill?sslmode=disable
  # replica for the application app
  appReplicas: 2
  # host aliases for all pods (can be overridden by individual components)
  hostAliases: []
  # Example:
  # hostAliases:
  #   - ip: "10.0.0.100"
  #     hostnames:
  #       - "gitlab-private.company.com"
  #       - "nexus.company.com"
  workerGroups:
    # workers configuration
    # The default worker group
    - name: "default"
      # -- Controller to use. Valid options are "Deployment" and "StatefulSet"
      controller: "Deployment"

      replicas: 3
      # -- Annotations to apply to the pods
      annotations: {}

      # -- If a job is being ran, the container will wait for it to finish before terminating until this grace period
      terminationGracePeriodSeconds: 604800

      # -- Labels to apply to the pods
      labels: {}

      # -- Node selector to use for scheduling the pods
      nodeSelector: {}

      # -- Tolerations to apply to the pods
      tolerations: []

      # -- Host aliases to apply to the pods (overrides global hostAliases if set)
      hostAliases: []

      # -- Whether to run the container as privileged (true by default). 
      # -- Needed to use proper OOM killer on k8s v1.32+ and use unshare pid for security reasons.
      privileged: true

      # -- Security context to apply to the container
      podSecurityContext:
        # -- run as user. The default is 0 for root user
        runAsUser: 0
        # -- run explicitly as a non-root user. The default is false.
        runAsNonRoot: false
      # -- Security context to apply to the pod
      containerSecurityContext: {}

      # -- Affinity rules to apply to the pods
      affinity: {}

      # -- Resource limits and requests for the pods
      resources:
        limits:
          memory: "2Gi"

      # -- Extra environment variables to apply to the pods
      extraEnv: []
      # -- Extra sidecar containers
      extraContainers: []
      mode: "worker"

      # -- Init containers
      initContainers: []
      volumes: []
      volumeMounts: []

      # -- Volume claim templates. Only applies when controller is "StatefulSet"
      volumeClaimTemplates: []

      # -- command override
      command: []

      # -- mount the docker socket inside the container to be able to run docker command as docker client to the host docker daemon
      exposeHostDocker: false

    - name: "native"
      # -- Controller to use. Valid options are "Deployment" and "StatefulSet"
      controller: "Deployment"

      replicas: 1
      # -- Annotations to apply to the pods
      annotations: {}

      # -- Labels to apply to the pods
      labels: {}

      # -- Node selector to use for scheduling the pods
      nodeSelector: {}

      # -- Tolerations to apply to the pods
      tolerations: []

      # -- Host aliases to apply to the pods (overrides global hostAliases if set)
      hostAliases: []

      # -- Whether to run the container as privileged (false by default). 
      # -- Not needed for native workers as they use a different memory management and isolation mechanism.
      privileged: false

      # -- Security context to apply to the container
      podSecurityContext:
        # -- run as user. The default is 0 for root user
        runAsUser: 0
        # -- run explicitly as a non-root user. The default is false.
        runAsNonRoot: false
      # -- Security context to apply to the pod
      containerSecurityContext: {}

      # -- Affinity rules to apply to the pods
      affinity: {}

      # -- Resource limits and requests for the pods
      resources:
        limits:
          memory: "2Gi"

      # -- Extra environment variables to apply to the pods
      extraEnv:
        - name: "NUM_WORKERS"
          value: "8"
        - name: "SLEEP_QUEUE"
          value: "200"
      # -- Extra sidecar containers
      extraContainers: []

      mode: "worker"

      volumes: []
      volumeMounts: []

      # -- mount the docker socket inside the container to be able to run docker command as docker client to the host docker daemon
      exposeHostDocker: false

      # -- Volume claim templates. Only applies when controller is "StatefulSet"
      volumeClaimTemplates: []

  # replicas for windmill-extra (set to 0 to disable)
  extraReplicas: 1

  # windmill-extra configuration (unified LSP, Multiplayer, and Debugger container)
  windmillExtra:
    # -- enable LSP (Language Server Protocol) for code completion
    enableLsp: true
    # -- enable Debugger for debugging scripts
    enableDebugger: true
    # -- require signed debug requests (JWT tokens for debug sessions)
    requireSignedDebugRequests: true

  # Use those to override the tag or image used for the app and worker containers. Windmill uses the same image for both.
  # By default, if enterprise is enable, the image is set to ghcr.io/windmill-labs/windmill-ee, otherwise the image is set to ghcr.io/windmill-labs/windmill
  #tag: "mytag"
  #image: "ghcr.io/windmill-labs/windmill"

# enable postgres on kubernetes, only for testing purposes
postgresql:
  enabled: true

# enable minio on kubernetes
minio:
  enabled: false

# Configure Ingress
# ingress:
#   className: ""

# enable enterprise features
enterprise:
  # -- enable windmill enterprise, requires license key.
  enabled: false
```

## Full Values

| Key                                                             | Type   | Default                                                                                    | Description                                                                                                                                                                                                      |
| --------------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| enterprise.enabled                                              | bool   | `false`                                                                                    | enable Windmill Enterprise , requires license key.                                                                                                                                                               |
| enterprise.enabledS3DistributedCache                            | bool   | `false`                                                                                    |                                                                                                                                                                                                                  |
| enterprise.licenseKey                                           | string | `"123456F"`                                                                                | Windmill provided Enterprise license key. Sets LICENSE_KEY environment variable in app and worker container.                                                                                                     |
| enterprise.licenseKeySecretName                                 | string | `""`                                                                                       | name of the secret storing the Enterprise license key, take precedence over licenseKey. The default key is `"licenseKey"`                                                                                        |
| enterprise.nsjail                                               | bool   | `false`                                                                                    | use nsjail for sandboxing                                                                                                                                                                                        |
| enterprise.s3CacheBucket                                        | string | `"mybucketname"`                                                                           | S3 bucket to use for dependency cache. Sets S3_CACHE_BUCKET environment variable in worker container                                                                                                             |
| enterprise.samlMetadata                                         | string | `""`                                                                                       | SAML Metadata URL to enable SAML SSO (Can be set in the Instance Settings UI, which is the recommended method)                                                                                                   |
| enterprise.scimToken                                            | string | `""`                                                                                       |                                                                                                                                                                                                                  |
| extraDeploy                                                     | list   | `[]`                                                                                       | Support for deploying additional arbitrary resources. Use for External Secrets, ConfigMaps, etc.                                                                                                                 |
| ingress.annotations                                             | object | `{}`                                                                                       |                                                                                                                                                                                                                  |
| ingress.className                                               | string | `""`                                                                                       |                                                                                                                                                                                                                  |
| ingress.enabled                                                 | bool   | `true`                                                                                     | enable/disable included ingress resource                                                                                                                                                                         |
| ingress.tls                                                     | list   | `[]`                                                                                       | TLS config for the ingress resource. Useful when using cert-manager and nginx-ingress                                                                                                                            |
| httproute.enabled                                               | bool   | `false`                                                                                    | enable/disable included httproute resource. This feature is experimental, for use with Gateway API: https://gateway-api.sigs.k8s.io/api-types/httproute/                                                                                                                            |
| httproute.parentRefs                                            | list   | `[]`                                                                                    |  Define which Gateways this Route wants to be attached tohttproute/                                                                                                                            |
| minio.auth.rootPassword                                         | string | `"windmill"`                                                                               |                                                                                                                                                                                                                  |
| minio.auth.rootUser                                             | string | `"windmill"`                                                                               |                                                                                                                                                                                                                  |
| minio.enabled                                                   | bool   | `false`                                                                                    | enabled included Minio operator for s3 resource demo purposes                                                                                                                                                    |
| minio.fullnameOverride                                          | string | `"windmill-minio"`                                                                         |                                                                                                                                                                                                                  |
| minio.mode                                                      | string | `"standalone"`                                                                             |                                                                                                                                                                                                                  |
| minio.primary.enabled                                           | bool   | `true`                                                                                     |                                                                                                                                                                                                                  |
| postgresql.auth.database                                        | string | `"windmill"`                                                                               |                                                                                                                                                                                                                  |
| postgresql.auth.postgresPassword                                | string | `"windmill"`                                                                               |                                                                                                                                                                                                                  |
| postgresql.enabled                                              | bool   | `true`                                                                                     | enabled included Postgres container for demo purposes only using bitnami                                                                                                                                         |
| postgresql.fullnameOverride                                     | string | `"windmill-postgresql"`                                                                    |                                                                                                                                                                                                                  |
| postgresql.primary.persistence.enabled                          | bool   | `true`                                                                                     |                                                                                                                                                                                                                  |
| serviceAccount.annotations                                      | object | `{}`                                                                                       |                                                                                                                                                                                                                  |
| serviceAccount.create                                           | bool   | `true`                                                                                     |                                                                                                                                                                                                                  |
| serviceAccount.name                                             | string | `""`                                                                                       |                                                                                                                                                                                                                  |
| windmill.app.affinity                                           | object | `{}`                                                                                       | Affinity rules to apply to the pods                                                                                                                                                                              |
| windmill.app.annotations                                        | object | `{}`                                                                                       | Annotations to apply to the pods                                                                                                                                                                                 |
| windmill.app.autoscaling.enabled                                | bool   | `false`                                                                                    | enable or disable autoscaling                                                                                                                                                                                    |
| windmill.app.autoscaling.maxReplicas                            | int    | `10`                                                                                       | maximum autoscaler replicas                                                                                                                                                                                      |
| windmill.app.autoscaling.targetCPUUtilizationPercentage         | int    | `80`                                                                                       | target CPU utilization                                                                                                                                                                                           |
| windmill.app.extraEnv                                           | list   | `[]`                                                                                       | Extra environment variables to apply to the pods                                                                                                                                                                 |
| windmill.app.hostAliases                                        | list   | `[]`                                                                                       | Host aliases to apply to the pods (overrides global hostAliases if set)                                                                                                                                         |
| windmill.app.labels                                             | object | `{}`                                                                                       | Labels to apply to the pods                                                                                                                                                                                      |
| windmill.app.nodeSelector                                       | object | `{}`                                                                                       | Node selector to use for scheduling the pods                                                                                                                                                                     |
| windmill.app.resources                                          | object | `{}`                                                                                       | Resource limits and requests for the pods                                                                                                                                                                        |
| windmill.app.tolerations                                        | list   | `[]`                                                                                       | Tolerations to apply to the pods                                                                                                                                                                                 |
| windmill.appReplicas                                            | int    | `2`                                                                                        | replica for the application app                                                                                                                                                                                  |
| windmill.baseDomain                                             | string | `"windmill"`                                                                               | domain as shown in browser, this variable and `baseProtocol` are used as part of the BASE_URL environment variable in app and worker container and in the ingress resource, if enabled                           |
| windmill.secondaryBaseDomain                                    | string | `""`                                                                                       | secondary domain that duplicates all ingress routes from baseDomain. Useful for having multiple domains point to the same services                                                                                |
| windmill.baseProtocol                                           | string | `"http"`                                                                                   | protocol as shown in browser, change to https etc based on your endpoint/ingress configuration, this variable and `baseDomain` are used as part of the BASE_URL environment variable in app and worker container |
| windmill.cookieDomain                                           | string | `""`                                                                                       | domain to use for the cookies. Use it if windmill is hosted on a subdomain and you need to share the cookies with the hub for instance                                                                           |
| windmill.databaseUrl                                            | string | `"postgres://postgres:windmill@windmill-postgresql/windmill?sslmode=disable"`              | Postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in app and worker container                                                                                 |
| windmill.databaseSecret                                         | bool   | `false`                                                                                    | Whether to create a secret containing the value of databaseUrl
| windmill.databaseUrlSecretName                                  | string | `""`                                                                                       | name of the secret storing the database URI, take precedence over databaseUrl. The key of the url is 'url'                                                                                                       |
| windmill.denoExtraImportMap                                     | string | `""`                                                                                       | custom deno extra import maps (syntax: `key1=value1,key2=value2`)                                                                                                                                                |
| windmill.exposeHostDocker                                       | bool   | `false`                                                                                    | mount the docker socket inside the container to be able to run docker command as docker client to the host docker daemon                                                                                         |
| windmill.globalErrorHandlerPath                                 | string | `""`                                                                                       | if set, the path to a script in the admins workspace that will be triggered upon any jobs failure                                                                                                                |
| windmill.hostAliases                                            | list   | `[]`                                                                                       | host aliases for all pods (can be overridden by individual components)                                                                                                                                           |
| windmill.image                                                  | string | `""`                                                                                       | windmill image tag, will use the Acorresponding ee or ce image from ghcr if not defined. Do not include tag in the image name.                                                                                   |
| windmill.instanceEventsWebhook                                  | string | `""`                                                                                       | send instance events to a webhook. Can be hooked back to windmill                                                                                                                                                |
| windmill.extraReplicas                                          | int    | `1`                                                                                        | replicas for windmill-extra (set to 0 to disable)                                                                                                                                                                |
| windmill.windmillExtra.image                                    | string | `""`                                                                                       | custom image (defaults to ghcr.io/windmill-labs/windmill-extra)                                                                                                                                                  |
| windmill.windmillExtra.tag                                      | string | `""`                                                                                       | custom image tag (defaults to the App version)                                                                                                                                                                   |
| windmill.windmillExtra.enableLsp                                | bool   | `true`                                                                                     | enable LSP (Language Server Protocol) for code completion                                                                                                                                                        |
| windmill.windmillExtra.enableDebugger                           | bool   | `true`                                                                                     | enable Debugger for debugging scripts                                                                                                                                                                            |
| windmill.windmillExtra.requireSignedDebugRequests               | bool   | `true`                                                                                     | require signed debug requests (JWT tokens for debug sessions)                                                                                                                                                    |
| windmill.windmillExtra.affinity                                 | object | `{}`                                                                                       | Affinity rules to apply to the pods                                                                                                                                                                              |
| windmill.windmillExtra.annotations                              | object | `{}`                                                                                       | Annotations to apply to the pods                                                                                                                                                                                 |
| windmill.windmillExtra.labels                                   | object | `{}`                                                                                       | Labels to apply to the pods                                                                                                                                                                                      |
| windmill.windmillExtra.nodeSelector                             | object | `{}`                                                                                       | Node selector to use for scheduling the pods                                                                                                                                                                     |
| windmill.windmillExtra.tolerations                              | list   | `[]`                                                                                       | Tolerations to apply to the pods                                                                                                                                                                                 |
| windmill.windmillExtra.resources                                | object | `{"limits":{"memory":"1Gi"}}`                                                              | Resource limits and requests for the pods                                                                                                                                                                        |
| windmill.windmillExtra.extraEnv                                 | list   | `[]`                                                                                       | Extra environment variables to apply to the pods                                                                                                                                                                 |
| windmill.npmConfigRegistry                                      | string | `""`                                                                                       | pass the npm for private registries                                                                                                                                                                              |
| windmill.pipExtraIndexUrl                                       | string | `""`                                                                                       | pass the extra index url to pip for private registries                                                                                                                                                           |
| windmill.pipIndexUrl                                            | string | `""`                                                                                       | pass the index url to pip for private registries                                                                                                                                                                 |
| windmill.pipTrustedHost                                         | string | `""`                                                                                       | pass the trusted host to pip for private registries                                                                                                                                                              |
| windmill.rustLog                                                | string | `"info"`                                                                                   | rust log level, set to debug for more information etc, sets RUST_LOG environment variable in app and worker container                                                                                            |
| windmill.tag                                                    | string | `""`                                                                                       | windmill app image tag, will use the App version if not defined                                                                                                                                                  |
| windmill.workerGroups[0].affinity                               | object | `{}`                                                                                       | Affinity rules to apply to the pods                                                                                                                                                                              |
| windmill.workerGroups[0].annotations                            | object | `{}`                                                                                       | Annotations to apply to the pods                                                                                                                                                                                 |
| windmill.workerGroups[0].extraEnv                               | list   | `[]`                                                                                       | Extra environment variables to apply to the pods                                                                                                                                                                 |
| windmill.workerGroups[0].extraContainers                        | list   | `[]`                                                                                       | Extra containers as sidecars                                                                                                                                                                                     |
| windmill.workerGroups[0].hostAliases                            | list   | `[]`                                                                                       | Host aliases to apply to the pods (overrides global hostAliases if set)                                                                                                                                         |
| windmill.workerGroups[0].labels                                 | object | `{}`                                                                                       | Labels to apply to the pods                                                                                                                                                                                      |
| windmill.workerGroups[0].name                                   | string | `"default"`                                                                                |                                                                                                                                                                                                                  |
| windmill.workerGroups[0].nodeSelector                           | object | `{}`                                                                                       | Node selector to use for scheduling the pods                                                                                                                                                                     |
| windmill.workerGroups[0].replicas                               | int    | `3`                                                                                        |                                                                                                                                                                                                                  |
| windmill.workerGroups[0].resources                              | object | `{"limits":{"cpu":"1000m","memory":"2048Mi"},"requests":{"cpu":"500m","memory":"1028Mi"}}` | Resource limits and requests for the pods                                                                                                                                                                        |
| windmill.workerGroups[0].tolerations                            | list   | `[]`                                                                                       | Tolerations to apply to the pods                                                                                                                                                                                 |
| windmill.workerGroups[0].mode                                   | string | `"worker"`                                                                                 | Mode for workers, "worker" or "agent", agent requires Enterprise                                                                                                                                                 |
| windmill.workerGroups[0].command                                | list   | `[]`                                                                                       | Command to run, overrides image default command                                                                                                                                                                  |
| windmill.workerGroups[1].affinity                               | object | `{}`                                                                                       | Affinity rules to apply to the pods                                                                                                                                                                              |
| windmill.workerGroups[1].annotations                            | object | `{}`                                                                                       | Annotations to apply to the pods                                                                                                                                                                                 |
| windmill.workerGroups[1].extraEnv                               | list   | `[]`                                                                                       | Extra environment variables to apply to the pods                                                                                                                                                                 |
| windmill.workerGroups[1].extraContainers                        | list   | `[]`                                                                                       | Extra containers as sidecars                                                                                                                                                                                     |
| windmill.workerGroups[1].hostAliases                            | list   | `[]`                                                                                       | Host aliases to apply to the pods (overrides global hostAliases if set)                                                                                                                                         |
| windmill.workerGroups[1].labels                                 | object | `{}`                                                                                       | Labels to apply to the pods                                                                                                                                                                                      |
| windmill.workerGroups[1].name                                   | string | `"gpu"`                                                                                    |                                                                                                                                                                                                                  |
| windmill.workerGroups[1].nodeSelector                           | object | `{}`                                                                                       | Node selector to use for scheduling the pods                                                                                                                                                                     |
| windmill.workerGroups[1].replicas                               | int    | `0`                                                                                        |                                                                                                                                                                                                                  |
| windmill.workerGroups[1].resources                              | object | `{}`                                                                                       | Resource limits and requests for the pods                                                                                                                                                                        |
| windmill.workerGroups[1].tolerations                            | list   | `[]`                                                                                       | Tolerations to apply to the pods                                                                                                                                                                                 |
| windmill.workerGroups[1].mode                                   | string | `"worker"`                                                                                 | Mode for workers, "worker" or "agent", agent requires Enterprise                                                                                                                                                 |
| windmill.workerGroups[1].command                                | list   | `[]`                                                                                       | Command to run, overrides image default command                                                                                                                                                                  |
| windmill.workerGroups[2].affinity                               | object | `{}`                                                                                       | Affinity rules to apply to the pods                                                                                                                                                                              |
| windmill.workerGroups[2].annotations                            | object | `{}`                                                                                       | Annotations to apply to the pods                                                                                                                                                                                 |
| windmill.workerGroups[2].extraEnv                               | list   | `[]`                                                                                       | Extra environment variables to apply to the pods                                                                                                                                                                 |
| windmill.workerGroups[2].extraContainers                        | list   | `[]`                                                                                       | Extra containers as sidecars                                                                                                                                                                                     |
| windmill.workerGroups[2].hostAliases                            | list   | `[]`                                                                                       | Host aliases to apply to the pods (overrides global hostAliases if set)                                                                                                                                         |
| windmill.workerGroups[2].labels                                 | object | `{}`                                                                                       | Labels to apply to the pods                                                                                                                                                                                      |
| windmill.workerGroups[2].name                                   | string | `"native"`                                                                                 |                                                                                                                                                                                                                  |
| windmill.workerGroups[2].nodeSelector                           | object | `{}`                                                                                       | Node selector to use for scheduling the pods                                                                                                                                                                     |
| windmill.workerGroups[2].replicas                               | int    | `4`                                                                                        |                                                                                                                                                                                                                  |
| windmill.workerGroups[2].resources                              | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}`    | Resource limits and requests for the pods                                                                                                                                                                        |
| windmill.workerGroups[2].tolerations                            | list   | `[]`                                                                                       | Tolerations to apply to the pods                                                                                                                                                                                 |
| windmill.workerGroups[2].mode                                   | string | `"worker"`                                                                                 | Mode for workers, "worker" or "agent", agent requires Enterprise                                                                                                                                                 |
| windmill.workerGroups[2].command                                | list   | `[]`                                                                                       | Command to run, overrides image default command                                                                                                                                                                  |

## Local S3

The chart includes a Minio S3 distribution to demonstrate the usage of S3 as a
resource in a vendor-agnostic environment like Kubernetes. The local Minio S3
service will be available to the Windmill workers through its Kubernetes
service, which is set to "windmill-minio" by default. In the Resources page, you
should create an S3 API Connection Object, and import it as a connection object
to reduce code duplication between scripts. For the sake of this example, this
stage is skipped. Below is an example of how to authenticate and use the
provided local S3 distribution in a Python script running in Windmill:

```python
from minio import Minio

def main():
    # Create a client with the MinIO server, its access key
    # and secret key.
    client = Minio(
        "windmill-minio", # Local Kubernetes Service
        access_key="windmill",
        secret_key="windmill",
    )

    # Make 'demo' bucket if not exist.
    found = client.bucket_exists("demo")
    if not found:
        client.make_bucket("demo")
    else:
        print("Bucket 'demo' already exists")

    with open('readme.txt', 'w') as f:
        f.write('Create a new text file!')

    client.fput_object(
        "demo", "readme.txt", "readme.txt",
    )

    print(
        "'readme.txt' is successfully uploaded as "
        "object 'readme.txt' to bucket 'demo'."
    )
```

## Enterprise features

To use the enterprise version with the <license key> provided upon subscription,
add the following to the values.yaml file:

```
enterprise:
  enabled: true
```

Then go to the superadmin settings -> instance settings -> license key and set
your license key

### S3 Cache

Enterprise users can use S3 storage for dependency caching for performance
reasons at high scale (use only with #workers > 20). Cache is two way synced at
regular intervals (10 minutes). To use it, the worker deployment requires access
to an S3 bucket. There are several ways to do this:

1. On AWS (and EKS) , you can use a service account with IAM roles attached. See
   [AWS docs](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html) -
   once you have a policy , you can create an account via eksctl for instance

   ```sh
   eksctl create iamserviceaccount --name serviceaccountname --namespace production --cluster windmill-cluster --role-name "iamrolename" \ --attach-policy-arn arn:aws:iam::12312315:policy/bucketpolicy --approve
   ```

2. Mount/attach a credentials file in `/root/.aws/credentials` of the worker
   deployment
3. Add environment variables for the `AWS_ACCESS_KEY_ID` and
   `AWS_SECRET_ACCESS_KEY`, via kube secrets.

The sync relies on rclone and uses its methods of authentication to s3 per
[Rclone documentation](https://rclone.org/s3/#authentication)

Then the values settings become:

```
enterprise:
  enabled: true
  enabledS3DistributedCache: true
  s3CacheBucket: mybucketname
```

## Caveats

- Postgres is included for demo purposes, it is a stateful set with a small
  volume claim applied. If you want to host postgres in k8s, there are better
  ways, or offload it outside your k8s cluster. Postgres can be disabled
  entirely in the values.yaml file.
- The postgres user/pass is currently not a secret/encrypted

## Kubernetes Hosting Tips

### Ingress configuration

The helm chart does have an ingress configuration included. It's enabled by
default. The ingress uses the `windmill.baseDomain` variable for its hostname
configuration. Here are example configurations for a few cloud providers.

It configures the HTTP ingress for the app and windmill-extra containers (LSP, Multiplayer, Debugger). The
configuration (except for plain nginx ingress) also exposes the windmill app
SMTP service for email triggers on a separate IP address/domain name. This is
the IP address/domain name you need to point your MX/A records to, learn more
[here](https://www.windmill.dev/docs/advanced/email_triggers).

### AWS ALB

```yaml
windmill:
  baseDomain: "windmill.example.com"
  app:
    smtpService:
      enabled: true
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: "external"
        service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
        service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
        # # for static ip (more info on https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/guide/service/annotations/#eip-allocations):
        # service.beta.kubernetes.io/aws-load-balancer-eip-allocations: eipalloc-xxxxxxxxxxxxxxxxx,eipalloc-yyyyyyyyyyyyyyyyy
    ...
  ...
...

ingress:
  className: "alb"
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/tags: Environment=dev,Team=test
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/target-group-attributes: stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=604800,stickiness.type=lb_cookie
    alb.ingress.kubernetes.io/load-balancer-attributes: idle_timeout.timeout_seconds=600
    alb.ingress.kubernetes.io/group.name: windmill
    alb.ingress.kubernetes.io/group.order: '10'
    alb.ingress.kubernetes.io/certificate-arn: my-certificatearn
```

### GCP + GCE LB + managed certificates

```yaml
windmill:
  baseDomain: "windmill.example.com"
  app:
    service:
      annotations:
        cloud.google.com/backend-config: '{"default": "session-config"}'
    smtpService:
      enabled: true
      annotations:
        cloud.google.com/l4-rbs: "enabled"
        # # for static ip (more info on https://cloud.google.com/kubernetes-engine/docs/concepts/service-load-balancer-parameters#spd-static-ip-parameters):
        # networking.gke.io/load-balancer-ip-addresses: <REGIONAL_IP_NAME>
  windmillExtra:
    service:
      annotations:
        cloud.google.com/backend-config: '{"default": "session-config"}'

ingress:
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: <GLOBAL_IP_NAME>
    networking.gke.io/managed-certificates: managed-cert
```

Replace `<GLOBAL_IP_NAME>` with the name of a global static IP address you've
created in GCP.

In addition to the above, you will need to apply the following resources for
session affinity and managed certificates:

```yaml
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: windmill-backendconfig
spec:
  sessionAffinity:
    affinityType: "GENERATED_COOKIE"
    affinityCookieTtlSec: 86400 # max
```

```yaml
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: managed-cert
spec:
  domains:
    - windmill.example.com
```

### Azure + app routing + keyvault certificate

```yaml
windmill:
  baseDomain: "windmill.example.com"
  app:
    smtpService:
      enabled: true
      # # for static ip (more info on https://learn.microsoft.com/en-us/azure/aks/static-ip):
      # annotations:
      #   service.beta.kubernetes.io/azure-pip-name: <myAKSPublicIP>
ingress:
  annotations:
    kubernetes.azure.com/tls-cert-keyvault-uri: <KeyVaultCertificateUri>
  className: webapprouting.kubernetes.azure.com
  tls:
    - hosts:
        - "windmill.example.com"
      secretName: keyvault-windmill
```

You can find more details about SSL certificates with webapprouting in Azure
[here](https://learn.microsoft.com/en-us/azure/aks/app-routing-dns-ssl).

### NGINX ingress + cert-manager:

```yaml
windmill:
  baseDomain: "windmill.example.com"
  ...

ingress:
  className: "nginx"
  tls:
    - hosts:
        - "windmill.example.com"
      secretName: windmill-tls-cert
  annotations:
    cert-manager.io/issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/affinity-mode: "persistent"
    nginx.ingress.kubernetes.io/session-cookie-name: "route"
...
```

You will also need to install cert-manager and configure an issuer. More details
[here](https://cert-manager.io/docs/installation/#default-static-install) and
[here](https://cert-manager.io/docs/tutorials/acme/nginx-ingress/#step-6---configure-a-lets-encrypt-issuer).
Cert-manager can also be used with the other cloud providers.

## Extra Deploy

The `extraDeploy` parameter allows you to deploy additional arbitrary Kubernetes resources alongside Windmill. This is particularly useful for deploying External Secrets, ConfigMaps, custom Services, or any other Kubernetes resources that your Windmill deployment might need.

Add the `extraDeploy` array to your values.yaml file with the Kubernetes resources you want to deploy:

```yaml
extraDeploy:
  - apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: windmill-database-secret
      namespace: windmill
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: vault-backend
        kind: SecretStore
      target:
        name: windmill-db-credentials
        creationPolicy: Owner
      data:
      - secretKey: DATABASE_URL
        remoteRef:
          key: database/windmill
          property: url
```

Then reference the created secret in your Windmill configuration:

```yaml
windmill:
  databaseUrlSecretName: windmill-db-credentials
  databaseUrlSecretKey: DATABASE_URL
```

### Tailscale with TLS

```yaml
ingress:
  enabled: false
windmill:
  baseDomain: "mywindmill.example.ts.net"
  ...
```

You will also need to install the [tailscale operator](https://tailscale.com/kb/1236/kubernetes-operator)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: windmill
  namespace: windmill
spec:
  ingressClassName: tailscale
  rules:

  - host: mywindmill
    http:
      paths:
      - backend:
          service:
            name: windmill-extra
            port:
              number: 3001
        path: /ws/
        pathType: Prefix
      - backend:
          service:
            name: windmill-extra
            port:
              number: 3003
        path: /ws_debug/
        pathType: Prefix
  - host: mywindmill
    http:
      paths:
      - backend:
          service:
            name: windmill-app
            port:
              number: 8000
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - mywindmill
```

### Generic

There are many ways to expose an app and it will depend on the requirements of
your environment. If you don't want to use the included ingress and roll your
own, you can just disable it. Overall, you want the following endpoints
accessible included in the chart:

- windmill app on port 8000
- windmill-extra on port 3001 (LSP), port 3002 (Multiplayer, enterprise only), port 3003 (Debugger)
- metrics endpoints on port 8001 for the app and workers (ee only)
- windmill app smtp service on port 2525 for email triggers (need to be exposed
  on port 25)

If you are using Prometheus and if the enterprise edition is enabled, you can
scrape the windmill-app-metrics service on port 8001 at /metrics endpoint to
gather stats about the Windmill application.

### Docker dind configruation

If you don't want to run Docker using the host's Docker engine, you can use
Docker-in-Docker (dind). Below is the configuration:

```yaml
windmill:
  workerGroups:
    - name: "docker"
      replicas: 2
      volumes:
        - emptyDir: {}
          name: sock-dir
        - emptyDir: {}
          name: windmill-workspace
      volumeMounts:
        - mountPath: /var/run
          name: sock-dir
        - mountPath: /opt/windmill
          name: windmill-workspace
      extraContainers:
        - args:
            - --mtu=1450
          image: docker:27.2.1-dind
          imagePullPolicy: IfNotPresent
          name: dind
          resources:
            requests:
              cpu: "1000m"
            limits:
              memory: "2Gi"
          securityContext:
            privileged: true
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          volumeMounts:
            - mountPath: /opt/windmill
              name: windmill-workspace
            - mountPath: /var/run
              name: sock-dir
```

NOTE: the `windmill-workspace` volumeMount is used to share files between the
dind container and the worker container.

### Host Aliases

You can configure custom DNS mappings for pods to access internal services or resolve domain issues:

```yaml
windmill:
  # Global for all pods
  hostAliases:
    - ip: "10.0.0.100"
      hostnames:
        - "internal-registry.company.com"
  
  # Per worker group
  workerGroups:
    - name: "default"
      hostAliases:
        - ip: "10.0.0.101"
          hostnames:
            - "private-pypi.company.com"
```

See [Kubernetes hostAliases documentation](https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/) for more details.

<!--
