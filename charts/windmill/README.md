# windmill

![Version: 4.0.174](https://img.shields.io/badge/Version-4.0.174-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.721.0](https://img.shields.io/badge/AppVersion-1.721.0-informational?style=flat-square)

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
| https://charts.min.io/ | minio | 5.4.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| enterprise.createKubernetesAutoscalingRolesAndBindings | bool | `false` | Create RBAC Roles and RoleBindings needed for native k8s autoscaling integration. |
| enterprise.enabled | bool | `false` | enable Windmill Enterprise, requires license key. |
| enterprise.enabledS3DistributedCache | bool | `false` |  |
| enterprise.licenseKey | string | `""` | enterprise license key. (Recommended to avoid: It is recommended to pass it from the Instance settings UI instead) |
| enterprise.licenseKeySecretKey | string | `"licenseKey"` | name of the key in secret storing the enterprise license key. The default key is 'licenseKey' |
| enterprise.licenseKeySecretName | string | `""` | name of the secret storing the enterprise license key, take precedence over licenseKey string. |
| enterprise.metricsAddr | string | `"true"` | Bind address for metrics server. Sets METRICS_ADDR environment variable. |
| enterprise.nsjail | bool | `false` | Consider using Amazon Linux 2/2023 AMI or configure Bottlerocket kernel parameters via launch template. |
| enterprise.s3CacheBucket | string | `""` | S3 bucket to use for dependency cache. Sets S3_CACHE_BUCKET environment variable in worker container |
| enterprise.samlMetadata | string | `""` | SAML Metadata URL/Content to enable SAML SSO (Can be set in the Instance Settings UI which is the recommended method) |
| enterprise.scimToken | string | `""` | SCIM token (Can be set in the instance settings UI which is the recommended method) |
| enterprise.scimTokenSecretKey | string | `"scimToken"` | name of the key in secret storing the SCIM token. The default key of the SCIM token is 'scimToken' |
| enterprise.scimTokenSecretName | string | `""` | name of the secret storing the SCIM token, takes precedence over SCIM token string. |
| extraDeploy | list | `[]` | Support for deploying additional arbitrary resources. Use for External Secrets, etc. |
| httproute.appParentRefs | list | `[]` | override parentRefs for the windmill app httproute (falls back to parentRefs) |
| httproute.enabled | bool | `false` | enable/disable creation of a httproute resource (experimental) |
| httproute.hubParentRefs | list | `[]` | override parentRefs for the windmill hub httproute (falls back to parentRefs) |
| httproute.parentRefs | list | `[]` | default parentRefs for all httproutes |
| httproute.publicAppDomainParentRefs | list | `[]` | override parentRefs for the publicAppDomain httproute (falls back to parentRefs) |
| httproute.secondaryApiDomainParentRefs | list | `[]` | override parentRefs for the secondaryApiDomain httproute (falls back to parentRefs) |
| httproute.secondaryBaseDomainParentRefs | list | `[]` | override parentRefs for the secondaryBaseDomain httproute (falls back to parentRefs) |
| hub-postgresql.auth.database | string | `"windmillhub"` |  |
| hub-postgresql.auth.postgresPassword | string | `"windmill"` |  |
| hub-postgresql.auth.postgresUser | string | `"postgres"` |  |
| hub-postgresql.enabled | bool | `false` | enabled included Postgres container for demo purposes |
| hub-postgresql.persistence | object | `{"accessMode":"ReadWriteOnce","enabled":false,"size":"50Gi","storageClass":""}` | persistence configuration for PostgreSQL data |
| hub-postgresql.persistence.accessMode | string | `"ReadWriteOnce"` | access mode for the PVC |
| hub-postgresql.persistence.enabled | bool | `false` | enable persistence using PVC |
| hub-postgresql.persistence.size | string | `"50Gi"` | size of the PVC |
| hub-postgresql.persistence.storageClass | string | `""` | storage class for the PVC (leave empty for default) |
| hub-postgresql.resources.limits.memory | string | `"2Gi"` |  |
| hub.affinity | object | `{}` | Affinity rules to apply to the pods |
| hub.annotations | object | `{}` | Annotations to apply to the pods |
| hub.apiSecret | string | `""` | API secret for the hub. Optional, only set if you want to restrict access to the hub. |
| hub.apiSecretSecretKey | string | `"apiSecret"` | name of the key in secret storing the API secret. The default key of the api secret is 'apiSecret' |
| hub.apiSecretSecretName | string | `""` | name of the secret storing the API secret, take precedence over apiSecret |
| hub.appAccessibleUrl | string | `""` | URL the hub renders in the browser for links pointing back to the Windmill app (PUBLIC_APP_ACCESSIBLE_URL). When unset, the hub falls back to `appUrl`. Set this to your external URL when `appUrl` is an internal cluster URL. |
| hub.appUrl | string | `""` | URL the hub uses for server-side requests to the Windmill app (PUBLIC_APP_URL). Defaults to `{windmill.baseProtocol}://{windmill.baseDomain}`. Set to an internal cluster URL (e.g. `http://windmill-app:8000`) to avoid TLS validation issues when the external ingress uses a self-signed certificate. |
| hub.baseDomain | string | `"hub.windmill"` | you also need to set the cookieDomain to the root domain in the app configuration |
| hub.baseProtocol | string | `"http"` | protocol as shown in browser, change to https etc based on your endpoint/ingress configuration, this variable and `baseDomain` are used as part of the BASE_URL environment variable in app and worker container |
| hub.containerSecurityContext | object | `{}` |  |
| hub.databaseSecret | bool | `false` | whether to create a secret containing the value of databaseUrl |
| hub.databaseUrl | string | `"postgres://postgres:windmill@windmill-hub-postgresql/windmillhub?sslmode=disable"` | Postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in app and worker container |
| hub.databaseUrlSecretKey | string | `"url"` | name of the key in secret storing the database URI. The default key of the url is 'url' |
| hub.databaseUrlSecretName | string | `""` | name of the secret storing the database URI, take precedence over databaseUrl. |
| hub.dnsConfig | object | `{}` | Custom DNS configuration for the pods. Falls back to windmill.dnsConfig when unset |
| hub.dnsPolicy | string | `""` | DNS policy for the pods. Valid options are "ClusterFirst", "Default", "ClusterFirstWithHostNet", "None". Falls back to windmill.dnsPolicy when unset |
| hub.enabled | bool | `false` | enable Windmill Hub, requires Windmill Enterprise and license key |
| hub.extraContainers | list | `[]` | Extra sidecar containers |
| hub.extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| hub.image | string | `""` | image |
| hub.initContainers | list | `[]` | Extra init containers |
| hub.labels | object | `{}` | Annotations to apply to the pods |
| hub.licenseKey | string | `""` | enterprise license key, deprecated use the enterprise values instead |
| hub.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| hub.podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the pods |
| hub.podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| hub.podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| hub.replicas | int | `1` | replicas for the hub |
| hub.resources | object | `{"limits":{"memory":"2Gi"}}` | Resource limits and requests for the pods |
| hub.securityContext | string | `nil` | legacy, use podSecurityContext instead |
| hub.serviceAccount.name | string | `""` | Name of an existing ServiceAccount to use for the hub pods. If empty, falls back to the chart's main ServiceAccount (see `serviceAccount` at the top level). Set this to bind a dedicated SA for IRSA (EKS) / Workload Identity (GKE). |
| hub.tag | string | `"1.2.0"` |  |
| hub.tolerations | list | `[]` | Tolerations to apply to the pods |
| hub.volumeMounts | list | `[]` | volumeMounts |
| hub.volumes | list | `[]` | volumes |
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
| postgresql.auth.postgresUser | string | `"postgres"` |  |
| postgresql.enabled | bool | `true` | enabled included Postgres container for demo purposes only using cloudnative-pg |
| postgresql.persistence | object | `{"accessMode":"ReadWriteOnce","enabled":false,"size":"50Gi","storageClass":""}` | persistence configuration for PostgreSQL data |
| postgresql.persistence.accessMode | string | `"ReadWriteOnce"` | access mode for the PVC |
| postgresql.persistence.enabled | bool | `false` | enable persistence using PVC |
| postgresql.persistence.size | string | `"50Gi"` | size of the PVC |
| postgresql.persistence.storageClass | string | `""` | storage class for the PVC (leave empty for default) |
| postgresql.resources.limits.memory | string | `"2Gi"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | string | `nil` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| windmill.app.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.app.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.app.autoscaling.enabled | bool | `false` | enable or disable autoscaling |
| windmill.app.autoscaling.maxReplicas | int | `10` | maximum autoscaler replicas |
| windmill.app.autoscaling.targetCPUUtilizationPercentage | int | `80` | target CPU utilization |
| windmill.app.containerSecurityContext | object | `{}` |  |
| windmill.app.dnsConfig | object | `{}` | Custom DNS configuration for the pods. Falls back to windmill.dnsConfig when unset |
| windmill.app.dnsPolicy | string | `""` | DNS policy for the pods. Valid options are "ClusterFirst", "Default", "ClusterFirstWithHostNet", "None". Falls back to windmill.dnsPolicy when unset |
| windmill.app.extraContainers | list | `[]` | Extra sidecar containers |
| windmill.app.extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.app.hostAliases | list | `[]` | Host aliases to apply to the pods (overrides global hostAliases if set) |
| windmill.app.initContainers | list | `[]` | Init containers |
| windmill.app.labels | object | `{}` | Annotations to apply to the pods |
| windmill.app.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.app.podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the pods |
| windmill.app.podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.app.podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.app.resources | object | `{"limits":{"memory":"2Gi"}}` | Resource limits and requests for the pods |
| windmill.app.securityContext | object | `{}` | legacy, use podSecurityContext instead |
| windmill.app.service.annotations | object | `{}` | Annotations to apply to the service |
| windmill.app.smtpService | object | `{"annotations":{},"enabled":false}` | smtp service configuration for email triggers |
| windmill.app.smtpService.annotations | object | `{}` | annotations to apply to the service |
| windmill.app.smtpService.enabled | bool | `false` | whether to expose the smtp port of the app using a load balancer service |
| windmill.app.smtpTls | object | `{"acme":{"dnsProvider":"dns_cf","dnsSecretName":"","domain":"","enabled":false,"image":"neilpang/acme.sh","imageTag":"latest","keyLength":2048,"nodeSelector":{},"renewBeforeDays":30,"resources":{"limits":{"cpu":"200m","memory":"128Mi"},"requests":{"cpu":"50m","memory":"64Mi"}},"schedule":"0 3 * * *","server":"https://acme-v02.api.letsencrypt.org/directory","tolerations":[]},"certSecretKey":"tls.crt","certSecretName":"","enabled":false,"keySecretKey":"tls.key"}` | SMTP TLS certificate configuration for the inbound email server (port 2525). Mount a TLS certificate from a Kubernetes Secret so acme.sh / cert-manager issued certs are used instead of the auto-generated self-signed certificate. The private key must be in PKCS#8 PEM format (openssl pkcs8 -topk8 -nocrypt -in key.pem -out key_pkcs8.pem). Certificates are hot-reloaded from disk every 12 hours (no restart needed on renewal). |
| windmill.app.smtpTls.acme | object | `{"dnsProvider":"dns_cf","dnsSecretName":"","domain":"","enabled":false,"image":"neilpang/acme.sh","imageTag":"latest","keyLength":2048,"nodeSelector":{},"renewBeforeDays":30,"resources":{"limits":{"cpu":"200m","memory":"128Mi"},"requests":{"cpu":"50m","memory":"64Mi"}},"schedule":"0 3 * * *","server":"https://acme-v02.api.letsencrypt.org/directory","tolerations":[]}` | Automated certificate issuance/renewal via acme.sh with DNS-01 challenge. Stores the cert in the same K8s Secret referenced by certSecretName above. |
| windmill.app.smtpTls.acme.dnsProvider | string | `"dns_cf"` | acme.sh DNS plugin name (e.g., dns_cf, dns_aws, dns_gd) |
| windmill.app.smtpTls.acme.dnsSecretName | string | `""` | name of an existing Secret containing DNS provider credentials (e.g., CF_Token, CF_Zone_ID) |
| windmill.app.smtpTls.acme.domain | string | `""` | domain to issue the certificate for (e.g., mx.example.com) |
| windmill.app.smtpTls.acme.enabled | bool | `false` | enable the acme.sh CronJob for automatic cert issuance/renewal |
| windmill.app.smtpTls.acme.image | string | `"neilpang/acme.sh"` | acme.sh container image |
| windmill.app.smtpTls.acme.imageTag | string | `"latest"` | acme.sh container image tag |
| windmill.app.smtpTls.acme.keyLength | int | `2048` | RSA key length for the certificate |
| windmill.app.smtpTls.acme.nodeSelector | object | `{}` | node selector for the CronJob pod |
| windmill.app.smtpTls.acme.renewBeforeDays | int | `30` | only renew when fewer than this many days remain before expiry |
| windmill.app.smtpTls.acme.resources | object | `{"limits":{"cpu":"200m","memory":"128Mi"},"requests":{"cpu":"50m","memory":"64Mi"}}` | resource limits and requests for the CronJob pod |
| windmill.app.smtpTls.acme.schedule | string | `"0 3 * * *"` | cron schedule for the renewal check (default: daily at 03:00 UTC) |
| windmill.app.smtpTls.acme.server | string | `"https://acme-v02.api.letsencrypt.org/directory"` | ACME server URL (default: Let's Encrypt production) |
| windmill.app.smtpTls.acme.tolerations | list | `[]` | tolerations for the CronJob pod |
| windmill.app.smtpTls.certSecretKey | string | `"tls.crt"` | key in the Secret for the certificate PEM file |
| windmill.app.smtpTls.certSecretName | string | `""` | name of the Kubernetes Secret containing the certificate and key |
| windmill.app.smtpTls.enabled | bool | `false` | enable mounting a TLS certificate for the SMTP server |
| windmill.app.smtpTls.keySecretKey | string | `"tls.key"` | key in the Secret for the private key PEM file (must be PKCS#8 format) |
| windmill.app.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.app.topologySpreadConstraints | list | `[]` | Topology spread constraints |
| windmill.app.volumeMounts | list | `[]` |  |
| windmill.app.volumes | list | `[]` | volumes |
| windmill.appReplicas | int | `2` | replica for the application app |
| windmill.baseDomain | string | `"windmill"` | domain as shown in browser. url of ths service is at: {baseProtocol}://{baseDomain} |
| windmill.baseProtocol | string | `"http"` | protocol as shown in browser, change to https etc based on your endpoint/ingress configuration, this variable and `baseDomain` are used as part of the BASE_URL environment variable in app and worker container |
| windmill.cookieDomain | string | `""` | domain to use for the cookies. Use it if windmill is hosted on a subdomain and you need to share the cookies with the hub for instance |
| windmill.databaseSecret | bool | `false` | whether to create a secret containing the value of databaseUrl |
| windmill.databaseUrl | string | `"postgres://postgres:windmill@windmill-postgresql/windmill?sslmode=disable"` | Postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in app and worker container |
| windmill.databaseUrlSecretKey | string | `"url"` | name of the key in existing secret storing the database URI. The default key of the url is 'url' |
| windmill.databaseUrlSecretName | string | `""` | name of the existing secret storing the database URI, take precedence over databaseUrl. |
| windmill.disableUnsharePid | bool | `false` | Some systems like Bottlerocket AMI have max_user_namespaces=0 which prevents unshare from working. |
| windmill.exposeHostDocker | bool | `false` | SECURITY RISK: mounts the host node's Docker socket into the worker, giving any user who can run a script root-equivalent control of the node's Docker daemon (and typically the cluster). Trusted, single-tenant use only — never enable for untrusted or multi-tenant workloads. Prefer a dedicated docker worker group with the rootless podman runtime (CONTAINER_RUNTIME=podman on a *-full image, run as a non-root user) instead. |
| windmill.extraReplicas | int | `1` | replicas for the lsp smart assistant (not required but useful for the web IDE) |
| windmill.dnsConfig | object | `{}` | DNS configuration for all Windmill pods. When dnsPolicy is "None", nameservers must include at least one resolver. Per-component dnsConfig replaces this value entirely (no deep merge) |
| windmill.dnsPolicy | string | `""` | DNS policy for all Windmill pods (app, workers, indexer, operator, extra, hub). Valid options are "ClusterFirst", "Default", "ClusterFirstWithHostNet", "None". Can be overridden per component or per worker group |
| windmill.exposeHostDocker | bool | `false` | mount the docker socket inside the container to be able to run docker command as docker client to the host docker daemon |
| windmill.hostAliases | list | `[]` | host aliases for all pods (can be overridden by individual worker groups) |
| windmill.image | string | `""` | windmill image tag, will use the Acorresponding ee or ce image from ghcr if not defined. Do not include tag in the image name. |
| windmill.imagePullPolicy | string | `"Always"` | image pull policy for the app, worker, lsp and multiplayer containers |
| windmill.imagePullSecrets | string | `""` | image pull secrets for windmill.  by default no image pull secrets will be configured. |
| windmill.indexer.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.indexer.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.indexer.containerSecurityContext | object | `{}` |  |
| windmill.indexer.dnsConfig | object | `{}` | Custom DNS configuration for the pods. Falls back to windmill.dnsConfig when unset |
| windmill.indexer.dnsPolicy | string | `""` | DNS policy for the pods. Valid options are "ClusterFirst", "Default", "ClusterFirstWithHostNet", "None". Falls back to windmill.dnsPolicy when unset |
| windmill.indexer.enabled | bool | `true` | enable or disable indexer |
| windmill.indexer.extraContainers | list | `[]` | Extra sidecar containers |
| windmill.indexer.extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.indexer.initContainers | list | `[]` | Extra init containers |
| windmill.indexer.labels | object | `{}` | Annotations to apply to the pods |
| windmill.indexer.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.indexer.podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the pods |
| windmill.indexer.podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.indexer.podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.indexer.resources | object | `{"limits":{"ephemeral-storage":"50Gi","memory":"2Gi"}}` | Resource limits and requests for the pods |
| windmill.indexer.securityContext | string | `nil` | legacy, use podSecurityContext instead |
| windmill.indexer.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.instanceEventsWebhook | string | `""` | send instance events to a webhook. Can be hooked back to windmill |
| windmill.multiplayerReplicas | int | `1` | replicas for the multiplayer containers used by the app (ee only and ignored if enterprise not enabled) |
| windmill.npmConfigRegistry | string | `""` | pass the npm for private registries |
| windmill.openaiAzureBasePath | string | `""` | configure a custom openai base path for azure |
| windmill.operator.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.operator.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.operator.containerSecurityContext | object | `{}` | Security context to apply to the container |
| windmill.operator.dnsConfig | object | `{}` | Custom DNS configuration for the pods. Falls back to windmill.dnsConfig when unset |
| windmill.operator.dnsPolicy | string | `""` | DNS policy for the pods. Valid options are "ClusterFirst", "Default", "ClusterFirstWithHostNet", "None". Falls back to windmill.dnsPolicy when unset |
| windmill.operator.enabled | bool | `false` | enable the Windmill Kubernetes operator |
| windmill.operator.extraContainers | list | `[]` | Extra sidecar containers |
| windmill.operator.extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.operator.labels | object | `{}` | Labels to apply to the pods |
| windmill.operator.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.operator.podSecurityContext | object | `{}` | Security context to apply to the pods |
| windmill.operator.replicas | int | `1` | number of operator replicas (typically 1) |
| windmill.operator.resources | object | `{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource limits and requests for the pods |
| windmill.operator.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.pipExtraIndexUrl | string | `""` | pass the extra index url to pip for private registries |
| windmill.pipIndexUrl | string | `""` | pass the index url to pip for private registries |
| windmill.pipTrustedHost | string | `""` | pass the trusted host to pip for private registries |
| windmill.publicAppDomain | string | `""` | domain to use for the public app. Use it for extra security so that custom apps cannot force the user to do custom api call on the main app |
| windmill.rustLog | string | `"info"` | rust log level, set to debug for more information etc, sets RUST_LOG environment variable in app and worker container |
| windmill.secondaryApiDomain | string | `""` | domain to use for the secondary api. Can be useful to have a secondary api domain that bypass a CDN like Cloudflare or similar. |
| windmill.secondaryBaseDomain | string | `""` | secondary domain that duplicates all ingress routes from baseDomain. Useful for having multiple domains point to the same services. |
| windmill.tag | string | `""` | windmill app image tag, will use the App version if not defined |
| windmill.windmillExtra.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.windmillExtra.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.windmillExtra.containerSecurityContext | object | `{}` | Security context to apply to the container |
| windmill.windmillExtra.dnsConfig | object | `{}` | Custom DNS configuration for the pods. Falls back to windmill.dnsConfig when unset |
| windmill.windmillExtra.dnsPolicy | string | `""` | DNS policy for the pods. Valid options are "ClusterFirst", "Default", "ClusterFirstWithHostNet", "None". Falls back to windmill.dnsPolicy when unset |
| windmill.windmillExtra.enableDebugger | bool | `true` | enable Debugger for debugging scripts |
| windmill.windmillExtra.enableGateway | bool | `true` | enable Gateway reverse proxy (routes /ws/*, /ws_mp/*, /ws_debug/* via a single port) |
| windmill.windmillExtra.enableLsp | bool | `true` | enable LSP (Language Server Protocol) for code completion |
| windmill.windmillExtra.extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.windmillExtra.image | string | `""` | custom image (defaults to ghcr.io/windmill-labs/windmill-extra) |
| windmill.windmillExtra.labels | object | `{}` | Labels to apply to the pods |
| windmill.windmillExtra.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.windmillExtra.podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the pods |
| windmill.windmillExtra.requireSignedDebugRequests | bool | `true` | require signed debug requests (JWT tokens for debug sessions) |
| windmill.windmillExtra.requireSignedMultiplayerRequests | bool | `true` | require signed multiplayer requests (JWT tokens for collaborative editing sessions). Keep enabled in production. |
| windmill.windmillExtra.resources | object | `{"limits":{"memory":"1Gi"}}` | Resource limits and requests for the pods |
| windmill.windmillExtra.securityContext | object | `{}` | legacy, use podSecurityContext instead |
| windmill.windmillExtra.service.annotations | object | `{}` | Annotations to apply to the service |
| windmill.windmillExtra.tag | string | `""` | custom image tag (defaults to the App version) |
| windmill.windmillExtra.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.windmillExtra.windmillBaseUrl | string | `""` | Set to your external URL (e.g. "https://windmill.example.com") if the debugger fails with token verification errors. |
| windmill.workerGroups[0].affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.workerGroups[0].annotations | object | `{}` | Annotations to apply to the pods |
| windmill.workerGroups[0].command | list | `[]` | command override |
| windmill.workerGroups[0].containerSecurityContext | object | `{}` | Security context to apply to the pod |
| windmill.workerGroups[0].controller | string | `"Deployment"` | Controller to use. Valid options are "Deployment" and "StatefulSet" |
| windmill.workerGroups[0].deploymentAnnotations | object | `{}` | Annotations to apply to the controller (Deployment/StatefulSet) itself |
| windmill.workerGroups[0].disableUnsharePid | bool | `false` | Set to true for nodes where user namespaces are disabled (e.g., Bottlerocket AMI with max_user_namespaces=0). |
| windmill.workerGroups[0].dnsConfig | object | `{}` | Custom DNS configuration for the pods. Useful for pods with VPN sidecars that need to resolve external DNS names |
| windmill.workerGroups[0].dnsPolicy | string | `""` | DNS policy for the pods. Set to "None" when using custom dnsConfig (e.g., for VPN sidecars or custom DNS resolution) |
| windmill.workerGroups[0].exposeHostDocker | bool | `false` | SECURITY RISK: mounts the host node's Docker socket into this worker group, giving any script author root-equivalent control of the node's Docker daemon. Trusted, single-tenant use only. Prefer the rootless podman runtime (CONTAINER_RUNTIME=podman on a *-full image, non-root) instead. |
| windmill.workerGroups[0].extraContainers | list | `[]` | Extra sidecar containers |
| windmill.workerGroups[0].extraEnv | list | `[]` | value: "/tmp" |
| windmill.workerGroups[0].hostAliases | list | `[]` | Host aliases to apply to the pods (overrides global hostAliases if set) |
| windmill.workerGroups[0].initContainers | list | `[]` | Init containers |
| windmill.workerGroups[0].labels | object | `{}` | Labels to apply to the pods |
| windmill.workerGroups[0].mode | string | `"worker"` |  |
| windmill.workerGroups[0].name | string | `"default"` |  |
| windmill.workerGroups[0].nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.workerGroups[0].podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the container |
| windmill.workerGroups[0].podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.workerGroups[0].podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.workerGroups[0].privileged | bool | `true` | Needed to use proper OOM killer on k8s v1.32+ and use unshare pid for security reasons. |
| windmill.workerGroups[0].replicas | int | `3` |  |
| windmill.workerGroups[0].resources | object | `{"limits":{"memory":"2Gi"}}` | Resource limits and requests for the pods |
| windmill.workerGroups[0].serviceAccountName | string | `""` | Falls back to the global service account when not set. |
| windmill.workerGroups[0].terminationGracePeriodSeconds | int | `604800` | If a job is being ran, the container will wait for it to finish before terminating until this grace period |
| windmill.workerGroups[0].tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.workerGroups[0].topologySpreadConstraints | list | `[]` |  |
| windmill.workerGroups[0].volumeClaimTemplates | list | `[]` | Volume claim templates. Only applies when controller is "StatefulSet" |
| windmill.workerGroups[0].volumeMounts | list | `[]` |  |
| windmill.workerGroups[0].volumes | list | `[]` |  |
| windmill.workerGroups[1].affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.workerGroups[1].annotations | object | `{}` | Annotations to apply to the pods |
| windmill.workerGroups[1].containerSecurityContext | object | `{}` | Security context to apply to the pod |
| windmill.workerGroups[1].controller | string | `"Deployment"` | Controller to use. Valid options are "Deployment" and "StatefulSet" |
| windmill.workerGroups[1].deploymentAnnotations | object | `{}` | Annotations to apply to the controller (Deployment/StatefulSet) itself |
| windmill.workerGroups[1].disableUnsharePid | bool | `false` | Set to true for nodes where user namespaces are disabled (e.g., Bottlerocket AMI with max_user_namespaces=0). |
| windmill.workerGroups[1].exposeHostDocker | bool | `false` | SECURITY RISK: mounts the host node's Docker socket into this worker group, giving any script author root-equivalent control of the node's Docker daemon. Trusted, single-tenant use only. Prefer the rootless podman runtime (CONTAINER_RUNTIME=podman on a *-full image, non-root) instead. |
| windmill.workerGroups[1].extraContainers | list | `[]` | Extra sidecar containers |
| windmill.workerGroups[1].extraEnv | list | `[{"name":"NATIVE_MODE","value":"true"},{"name":"SLEEP_QUEUE","value":"200"}]` | Extra environment variables to apply to the pods |
| windmill.workerGroups[1].hostAliases | list | `[]` | Host aliases to apply to the pods (overrides global hostAliases if set) |
| windmill.workerGroups[1].labels | object | `{}` | Labels to apply to the pods |
| windmill.workerGroups[1].mode | string | `"worker"` |  |
| windmill.workerGroups[1].name | string | `"native"` |  |
| windmill.workerGroups[1].nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.workerGroups[1].podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the container |
| windmill.workerGroups[1].podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.workerGroups[1].podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.workerGroups[1].privileged | bool | `false` | Not needed for native workers as they use a different memory management and isolation mechanism. |
| windmill.workerGroups[1].replicas | int | `1` |  |
| windmill.workerGroups[1].resources | object | `{"limits":{"memory":"2Gi"}}` | Resource limits and requests for the pods |
| windmill.workerGroups[1].serviceAccountName | string | `""` | Falls back to the global service account when not set. |
| windmill.workerGroups[1].tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.workerGroups[1].topologySpreadConstraints | list | `[]` |  |
| windmill.workerGroups[1].volumeClaimTemplates | list | `[]` | Volume claim templates. Only applies when controller is "StatefulSet" |
| windmill.workerGroups[1].volumeMounts | list | `[]` |  |
| windmill.workerGroups[1].volumes | list | `[]` |  |
| windmill.workerGroups[2].affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.workerGroups[2].annotations | object | `{}` | Annotations to apply to the pods |
| windmill.workerGroups[2].command | list | `[]` | command override |
| windmill.workerGroups[2].containerSecurityContext | object | `{}` | Security context to apply to the pod |
| windmill.workerGroups[2].controller | string | `"Deployment"` | Controller to use. Valid options are "Deployment" and "StatefulSet" |
| windmill.workerGroups[2].disableUnsharePid | bool | `false` | Set to true for nodes where user namespaces are disabled (e.g., Bottlerocket AMI with max_user_namespaces=0). |
| windmill.workerGroups[2].exposeHostDocker | bool | `false` | SECURITY RISK: mounts the host node's Docker socket into this worker group, giving any script author root-equivalent control of the node's Docker daemon. Trusted, single-tenant use only. Prefer the rootless podman runtime (CONTAINER_RUNTIME=podman on a *-full image, non-root) instead. |
| windmill.workerGroups[2].extraContainers | list | `[]` | Extra sidecar containers |
| windmill.workerGroups[2].extraEnv | list | `[]` | Extra environment variables to apply to the pods |
| windmill.workerGroups[2].hostAliases | list | `[]` | Host aliases to apply to the pods (overrides global hostAliases if set) |
| windmill.workerGroups[2].labels | object | `{}` | Labels to apply to the pods |
| windmill.workerGroups[2].mode | string | `"worker"` |  |
| windmill.workerGroups[2].name | string | `"gpu"` |  |
| windmill.workerGroups[2].nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.workerGroups[2].podSecurityContext | object | `{"runAsNonRoot":false,"runAsUser":0}` | Security context to apply to the container |
| windmill.workerGroups[2].podSecurityContext.runAsNonRoot | bool | `false` | run explicitly as a non-root user. The default is false. |
| windmill.workerGroups[2].podSecurityContext.runAsUser | int | `0` | run as user. The default is 0 for root user |
| windmill.workerGroups[2].privileged | bool | `true` | Needed to use proper OOM killer on k8s v1.32+ and use unshare pid for security reasons. |
| windmill.workerGroups[2].replicas | int | `0` |  |
| windmill.workerGroups[2].resources | object | `{"limits":{"memory":"2Gi"}}` | Resource limits and requests for the pods |
| windmill.workerGroups[2].serviceAccountName | string | `""` | Falls back to the global service account when not set. |
| windmill.workerGroups[2].tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.workerGroups[2].topologySpreadConstraints | list | `[]` |  |
| windmill.workerGroups[2].volumeClaimTemplates | list | `[]` | Volume claim templates. Only applies when controller is "StatefulSet" |
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

