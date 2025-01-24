# windmill

![Version: 2.0.266](https://img.shields.io/badge/Version-2.0.266-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.391.0](https://img.shields.io/badge/AppVersion-1.391.0-informational?style=flat-square)

Windmill - Turn scripts into endpoints, workflows and UIs in minutes

**Homepage:** <https://www.windmill.dev/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| windmill | <ruben@windmill.dev> | <https://www.windmill.dev/> |

## Source Code

* <https://github.com/windmill-labs/windmill-helm-charts.git>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | minio | 12.4.2 |
| https://charts.bitnami.com/bitnami | postgresql | 12.3.1 |
| https://charts.bitnami.com/bitnami | hub-postgresql(postgresql) | 12.3.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| enterprise.enabled | bool | `false` | enable Windmill Enterprise, requires license key. |
| enterprise.enabledS3DistributedCache | bool | `false` |  |
| enterprise.licenseKey | string | `""` | enterprise license key. (Recommended to avoid: It is recommended to pass it from the Instance settings UI instead) |
| enterprise.nsjail | bool | `false` | use nsjail for sandboxing |
| enterprise.s3CacheBucket | string | `""` | S3 bucket to use for dependency cache. Sets S3_CACHE_BUCKET environment variable in worker container |
| enterprise.samlMetadata | string | `""` | SAML Metadata URL/Content to enable SAML SSO (Can be set in the Instance Settings UI which is the recommended method) |
| enterprise.scimToken | string | `""` | SCIM token (Can be set in the instance settings UI which is the recommended method) |
| enterprise.scimTokenSecretKey | string | `"scimToken"` | name of the key in secret storing the SCIM token. The default key of the SCIM token is 'scimToken' |
| enterprise.scimTokenSecretName | string | `""` | name of the secret storing the SCIM token, takes precedence over SCIM token string. |
| hub-postgresql.auth.database | string | `"windmillhub"` |  |
| hub-postgresql.auth.postgresPassword | string | `"windmill"` |  |
| hub-postgresql.enabled | bool | `false` | enabled included Postgres container for demo purposes only using bitnami |
| hub-postgresql.fullnameOverride | string | `"windmill-hub-postgresql"` |  |
| hub-postgresql.primary.persistence.enabled | bool | `true` |  |
| hub-postgresql.primary.resources.limits.cpu | string | `"1"` |  |
| hub-postgresql.primary.resources.limits.memory | string | `"2Gi"` |  |
| hub-postgresql.primary.resources.requests.cpu | string | `"250m"` |  |
| hub-postgresql.primary.resources.requests.memory | string | `"1024Mi"` |  |
| hub.affinity | object | `{}` | Affinity rules to apply to the pods |
| hub.annotations | object | `{}` | Annotations to apply to the pods |
| hub.baseDomain | string | `"hub.windmill"` | you also need to set the cookieDomain to the root domain in the app configuration |
| hub.baseProtocol | string | `"http"` | protocol as shown in browser, change to https etc based on your endpoint/ingress configuration, this variable and `baseDomain` are used as part of the BASE_URL environment variable in app and worker container |
| hub.containerSecurityContext | object | `{}` |  |
| hub.databaseUrl | string | `"postgres://postgres:windmill@windmill-hub-postgresql/windmillhub?sslmode=disable"` | Postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in app and worker container |
| hub.databaseUrlSecretKey | string | `"url"` | name of the key in secret storing the database URI. The default key of the url is 'url' |
| hub.databaseUrlSecretName | string | `""` | name of the secret storing the database URI, take precedence over databaseUrl. |
| hub.enabled | bool | `false` | enable Windmill Hub, requires Windmill Enterprise and license key |
| hub.extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| hub.image | string | `""` | image |
| hub.labels | object | `{}` | Annotations to apply to the pods |
| hub.licenseKey | string | `""` | enterprise license key |
| hub.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| hub.podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the pods |
| hub.podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| hub.podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| hub.replicas | int | `1` | replicas for the hub |
| hub.resources | object | `{}` | Resource limits and requests for the pods |
| hub.securityContext | string | `nil` | legacy, use podSecurityContext instead |
| hub.tolerations | list | `[]` | Tolerations to apply to the pods |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `true` | enable/disable included ingress resource |
| ingress.tls | list | `[]` | TLS config for the ingress resource. Useful when using cert-manager and nginx-ingress |
| minio.auth.rootPassword | string | `"windmill"` |  |
| minio.auth.rootUser | string | `"windmill"` |  |
| minio.enabled | bool | `false` | enabled included Minio operator for s3 resource demo purposes |
| minio.fullnameOverride | string | `"windmill-minio"` |  |
| minio.mode | string | `"standalone"` |  |
| minio.primary.enabled | bool | `true` |  |
| postgresql.auth.database | string | `"windmill"` |  |
| postgresql.auth.postgresPassword | string | `"windmill"` |  |
| postgresql.enabled | bool | `true` | enabled included Postgres container for demo purposes only using bitnami |
| postgresql.fullnameOverride | string | `"windmill-postgresql"` |  |
| postgresql.primary.persistence.enabled | bool | `true` |  |
| postgresql.primary.resources.limits.cpu | string | `"1"` |  |
| postgresql.primary.resources.limits.memory | string | `"2Gi"` |  |
| postgresql.primary.resources.requests.cpu | string | `"250m"` |  |
| postgresql.primary.resources.requests.memory | string | `"1024Mi"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| windmill.app.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.app.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.app.autoscaling.enabled | bool | `false` | enable or disable autoscaling |
| windmill.app.autoscaling.maxReplicas | int | `10` | maximum autoscaler replicas |
| windmill.app.autoscaling.targetCPUUtilizationPercentage | int | `80` | target CPU utilization |
| windmill.app.containerSecurityContext | object | `{}` |  |
| windmill.app.extraContainers | list | `[]` | Extra sidecar containers |
| windmill.app.extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.app.initContainers | list | `[]` | Init containers |
| windmill.app.labels | object | `{}` | Annotations to apply to the pods |
| windmill.app.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.app.podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the pods |
| windmill.app.podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.app.podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.app.resources | object | `{"limits":{"cpu":"1","memory":"2Gi"}}` | Resource limits and requests for the pods |
| windmill.app.securityContext | object | `{}` | legacy, use podSecurityContext instead |
| windmill.app.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.app.volumes | list | `[]` | volumes |
| windmill.appReplicas | int | `2` | replica for the application app |
| windmill.baseDomain | string | `"windmill"` | domain as shown in browser. url of ths service is at: {baseProtocol}://{baseDomain} |
| windmill.baseProtocol | string | `"http"` | protocol as shown in browser, change to https etc based on your endpoint/ingress configuration, this variable and `baseDomain` are used as part of the BASE_URL environment variable in app and worker container |
| windmill.cookieDomain | string | `""` | domain to use for the cookies. Use it if windmill is hosted on a subdomain and you need to share the cookies with the hub for instance |
| windmill.databaseUrl | string | `"postgres://postgres:windmill@windmill-postgresql/windmill?sslmode=disable"` | Postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in app and worker container |
| windmill.databaseUrlSecretKey | string | `"url"` | name of the key in secret storing the database URI. The default key of the url is 'url' |
| windmill.databaseUrlSecretName | string | `""` | name of the secret storing the database URI, take precedence over databaseUrl. |
| windmill.exposeHostDocker | bool | `false` | mount the docker socket inside the container to be able to run docker command as docker client to the host docker daemon |
| windmill.image | string | `""` | windmill image tag, will use the Acorresponding ee or ce image from ghcr if not defined. Do not include tag in the image name. |
| windmill.imagePullSecrets | string | `""` | image pull secrets for windmill.  by default no image pull secrets will be configured. |
| windmill.instanceEventsWebhook | string | `""` | send instance events to a webhook. Can be hooked back to windmill |
| windmill.lsp.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.lsp.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.lsp.autoscaling.enabled | bool | `false` | enable or disable autoscaling |
| windmill.lsp.autoscaling.maxReplicas | int | `10` | maximum autoscaler replicas |
| windmill.lsp.autoscaling.targetCPUUtilizationPercentage | int | `80` | target CPU utilization |
| windmill.lsp.containerSecurityContext | object | `{}` |  |
| windmill.lsp.extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.lsp.labels | object | `{}` | Annotations to apply to the pods |
| windmill.lsp.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.lsp.podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the pods |
| windmill.lsp.podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.lsp.podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.lsp.resources | object | `{}` | Resource limits and requests for the pods |
| windmill.lsp.securityContext | string | `nil` | legacy, use podSecurityContext instead |
| windmill.lsp.tag | string | `"latest"` |  |
| windmill.lsp.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.lspReplicas | int | `2` | replicas for the lsp smart assistant (not required but useful for the web IDE) |
| windmill.multiplayer.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.multiplayer.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.multiplayer.autoscaling.enabled | bool | `false` | enable or disable autoscaling |
| windmill.multiplayer.autoscaling.maxReplicas | int | `10` | maximum autoscaler replicas |
| windmill.multiplayer.autoscaling.targetCPUUtilizationPercentage | int | `80` | target CPU utilization |
| windmill.multiplayer.containerSecurityContext | object | `{}` |  |
| windmill.multiplayer.extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.multiplayer.labels | object | `{}` | Annotations to apply to the pods |
| windmill.multiplayer.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.multiplayer.podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the pods |
| windmill.multiplayer.podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.multiplayer.podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.multiplayer.resources | object | `{}` | Resource limits and requests for the pods |
| windmill.multiplayer.securityContext | string | `nil` | legacy, use podSecurityContext instead |
| windmill.multiplayer.tag | string | `"latest"` |  |
| windmill.multiplayer.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.multiplayerReplicas | int | `1` | replicas for the multiplayer containers used by the app (ee only and ignored if enterprise not enabled) |
| windmill.npmConfigRegistry | string | `""` | pass the npm for private registries |
| windmill.openaiAzureBasePath | string | `""` | configure a custom openai base path for azure |
| windmill.pipExtraIndexUrl | string | `""` | pass the extra index url to pip for private registries |
| windmill.pipIndexUrl | string | `""` | pass the index url to pip for private registries |
| windmill.pipTrustedHost | string | `""` | pass the trusted host to pip for private registries |
| windmill.rustLog | string | `"info"` | rust log level, set to debug for more information etc, sets RUST_LOG environment variable in app and worker container |
| windmill.tag | string | `""` | windmill app image tag, will use the App version if not defined |
| windmill.workerGroups[0].affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.workerGroups[0].annotations | object | `{}` | Annotations to apply to the pods |
| windmill.workerGroups[0].command | list | `[]` | command override |
| windmill.workerGroups[0].containerSecurityContext | object | `{}` | Security context to apply to the pod |
| windmill.workerGroups[0].extraContainers | list | `[]` | Extra sidecar containers |
| windmill.workerGroups[0].extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.workerGroups[0].initContainers | list | `[]` | Init containers |
| windmill.workerGroups[0].labels | object | `{}` | Labels to apply to the pods |
| windmill.workerGroups[0].mode | string | `"worker"` |  |
| windmill.workerGroups[0].name | string | `"default"` |  |
| windmill.workerGroups[0].nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.workerGroups[0].podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the container |
| windmill.workerGroups[0].podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.workerGroups[0].podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.workerGroups[0].replicas | int | `3` |  |
| windmill.workerGroups[0].resources | object | `{"limits":{"cpu":"1","memory":"2Gi"}}` | Resource limits and requests for the pods |
| windmill.workerGroups[0].terminationGracePeriodSeconds | int | `604800` | If a job is being ran, the container will wait for it to finish before terminating until this grace period |
| windmill.workerGroups[0].tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.workerGroups[0].volumeMounts | list | `[]` |  |
| windmill.workerGroups[0].volumes | list | `[]` |  |
| windmill.workerGroups[1].affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.workerGroups[1].annotations | object | `{}` | Annotations to apply to the pods |
| windmill.workerGroups[1].containerSecurityContext | object | `{}` | Security context to apply to the pod |
| windmill.workerGroups[1].extraContainers | list | `[]` | Extra sidecar containers |
| windmill.workerGroups[1].extraEnv | list | `[{"name":"NUM_WORKERS","value":"8"},{"name":"SLEEP_QUEUE","value":"200"}]` | Extra environment variables to apply to the pods |
| windmill.workerGroups[1].labels | object | `{}` | Labels to apply to the pods |
| windmill.workerGroups[1].mode | string | `"worker"` |  |
| windmill.workerGroups[1].name | string | `"native"` |  |
| windmill.workerGroups[1].nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.workerGroups[1].podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the container |
| windmill.workerGroups[1].podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.workerGroups[1].podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.workerGroups[1].replicas | int | `1` |  |
| windmill.workerGroups[1].resources | object | `{"limits":{"cpu":"1","memory":"2Gi"}}` | Resource limits and requests for the pods |
| windmill.workerGroups[1].tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.workerGroups[1].volumeMounts | list | `[]` |  |
| windmill.workerGroups[1].volumes | list | `[]` |  |
| windmill.workerGroups[2].affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.workerGroups[2].annotations | object | `{}` | Annotations to apply to the pods |
| windmill.workerGroups[2].command | list | `[]` | command override |
| windmill.workerGroups[2].containerSecurityContext | object | `{}` | Security context to apply to the pod |
| windmill.workerGroups[2].extraContainers | list | `[]` | Extra sidecar containers |
| windmill.workerGroups[2].extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.workerGroups[2].labels | object | `{}` | Labels to apply to the pods |
| windmill.workerGroups[2].mode | string | `"worker"` |  |
| windmill.workerGroups[2].name | string | `"gpu"` |  |
| windmill.workerGroups[2].nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.workerGroups[2].podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the container |
| windmill.workerGroups[2].podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.workerGroups[2].podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.workerGroups[2].replicas | int | `0` |  |
| windmill.workerGroups[2].resources | object | `{}` | Resource limits and requests for the pods |
| windmill.workerGroups[2].tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.workerGroups[2].volumeMounts | list | `[]` |  |
| windmill.workerGroups[2].volumes | list | `[]` |  |

## Keeping the PostgreSQL password secret

If you would prefer to keep the PostgreSQL password or connection string out of the Helm values, there are two different possible approaches:

1. Use `windmill.databaseUrlSecretName` to point at a Secret with a `url` key or another key set with `windmill.databaseUrlSecretKey` that contains the entire database connection string.

2. Use `windmill.databaseUrl` with [Dependent Environment Variables](https://kubernetes.io/docs/tasks/inject-data-application/define-interdependent-environment-variables/) together with `windmill.app.extraEnv` and `windmill.workers.extraEnv`.

An example of the second approach might use Helm values similar to this:

```yaml
windmill:
  databaseUrl: "postgres://windmill:$(DATABASE_PASSWORD)@windmill-postgres/windmill?sslmode=require"

  workers:
    extraEnv:
    - name: DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: windmill-postgres
          key: password

  app:
    extraEnv:
    - name: DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: windmill-postgres
          key: password
```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)
