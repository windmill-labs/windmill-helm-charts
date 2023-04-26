# windmill

![Version: 1.4.0](https://img.shields.io/badge/Version-1.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.89.0](https://img.shields.io/badge/AppVersion-1.89.0-informational?style=flat-square)

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
| https://charts.bitnami.com/bitnami | postgresql | 12.3.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| enterprise.enabled | bool | `false` | enable Windmill Enterprise , requires license key. |
| enterprise.licenseKey | string | `"123456F"` | Windmill provided Enterprise license key. Sets LICENSE_KEY environment variable in frontend and worker container. |
| enterprise.nsjail | bool | `false` | use nsjail for sandboxing |
| enterprise.s3CacheBucket | string | `"mybucketname"` | S3 bucket to use for dependency cache. Sets S3_CACHE_BUCKET environment variable in worker container |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| lsp | string | `"latest"` | lsp image tag |
| postgresql.auth.database | string | `"windmill"` |  |
| postgresql.auth.postgresPassword | string | `"windmill"` |  |
| postgresql.enabled | bool | `true` | enabled included Postgres container for demo purposes only using bitnami |
| postgresql.fullnameOverride | string | `"windmill-postgresql"` |  |
| postgresql.primary.persistence.enabled | bool | `true` |  |
| windmill.baseUrl | string | `"http://localhost"` | domain as shown in browser, change to https etc based on your endpoint/ingress configuration, sets BASE_URL environment variable in frontend and worker container |
| windmill.cookieDomain | string | `""` | domain to use for the cookies. Use it if windmill is hosted on a subdomain and you need to share the cookies with the hub for instance  |
| windmill.databaseUrl | string | `"postgres://postgres:windmill@windmill-postgresql/windmill?sslmode=disable"` | Postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in frontend and worker container |
| windmill.frontend.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.frontend.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.frontend.autoscaling.enabled | bool | `false` | enable or disable autoscaling |
| windmill.frontend.autoscaling.maxReplicas | int | `10` | maximum autoscaler replicas |
| windmill.frontend.autoscaling.targetCPUUtilizationPercentage | int | `80` | target CPU utilization |
| windmill.frontend.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.frontend.resources | object | `{}` | Resource limits and requests for the pods |
| windmill.frontend.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.frontendReplicas | int | `2` | replica for the application frontend |
| windmill.image | string | `"main"` | windmill app image tag |
| windmill.instanceEventsWebhook | string | `""` |  |
| windmill.lsp.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.lsp.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.lsp.autoscaling.enabled | bool | `false` | enable or disable autoscaling |
| windmill.lsp.autoscaling.maxReplicas | int | `10` | maximum autoscaler replicas |
| windmill.lsp.autoscaling.targetCPUUtilizationPercentage | int | `80` | target CPU utilization |
| windmill.lsp.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.lsp.resources | object | `{}` | Resource limits and requests for the pods |
| windmill.lsp.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.lspReplicas | int | `2` | replicas for the lsp containers used by the frontend |
| windmill.npmConfigRegistry | string | `""` | pass the npm for private registries |
| windmill.numWorkers | int | `1` | workers per worker container, default and recommended is 1 to isolate one process per container, sets NUM_WORKER environment variable for worker container.  Frontend container has 0 NUM_WORKERS by default |
| windmill.oauthConfig | string | `"{}\n"` | raw oauth config. See https://docs.windmill.dev/docs/misc/setup_oauth |
| windmill.oauthSecretName | string | `""` | name of the secret storing the oauthConfig. See https://docs.windmill.dev/docs/misc/setup_oauth |
| windmill.pipExtraIndexUrl | string | `""` | pass the extra index url to pip for private registries |
| windmill.pipIndexUrl | string | `""` | pass the index url to pip for private registries |
| windmill.pipTrustedHost | string | `""` | pass the trusted host to pip for private registries |
| windmill.rustLog | string | `"info"` | rust log level, set to debug for more information etc, sets RUST_LOG environment variable in frontend and worker container |
| windmill.workerGroups[0].affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.workerGroups[0].annotations | object | `{}` | Annotations to apply to the pods |
| windmill.workerGroups[0].name | string | `"gpu"` |  |
| windmill.workerGroups[0].nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.workerGroups[0].replicas | int | `1` |  |
| windmill.workerGroups[0].resources | object | `{}` | Resource limits and requests for the pods |
| windmill.workerGroups[0].tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.workerReplicas | int | `2` | replicas for the workers, jobs are executed on the workers |
| windmill.workers.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.workers.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.workers.autoscaling.enabled | bool | `false` | will not benefit from the global cache and the performances will be poor for newly spawned pods |
| windmill.workers.autoscaling.maxReplicas | int | `10` | maximum autoscaler replicas |
| windmill.workers.autoscaling.targetCPUUtilizationPercentage | int | `80` | target CPU utilization |
| windmill.workers.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.workers.resources | object | `{}` | Resource limits and requests for the pods |
| windmill.workers.tolerations | list | `[]` | Tolerations to apply to the pods |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
