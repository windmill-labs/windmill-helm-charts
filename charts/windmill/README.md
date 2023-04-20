# windmill

![Version: 1.1.3](https://img.shields.io/badge/Version-1.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.87.1](https://img.shields.io/badge/AppVersion-1.87.1-informational?style=flat-square)

A Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| enterprise.enabled | bool | `false` | enable Windmill Enterprise , requires license key. |
| enterprise.licenseKey | string | `"123456F"` | Windmill provided Enterprise license key. Sets LICENSE_KEY environment variable in frontend and worker container. |
| enterprise.s3CacheBucket | string | `"mybucketname"` | S3 bucket to use for dependency cache. Sets S3_CACHE_BUCKET environment variable in worker container |
| lsp | string | `"latest"` |  |
| postgres.dbName | string | `"windmill"` | database name for postgres demo container |
| postgres.enabled | bool | `true` | enabled included Postgres container for demo purposes only |
| postgres.password | string | `"changeme"` | password for postgres demo container |
| windmill.baseInternalUrl | string | `"http://windmill-app:8000"` | used internally by the app, should match the service for the frontend deployment, sets BASE_INTERNAL_URL environment variable in frontend and worker container |
| windmill.baseUrl | string | `"http://localhost"` | domain as shown in browser, change to https etc based on your endpoint/ingress configuration, sets BASE_URL environment variable in frontend and worker container |
| windmill.databaseUrl | string | `"postgres://postgres:changeme@postgres/windmill?sslmode=disable"` | Postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in frontend and worker container |
| windmill.denoPath | string | `"/usr/bin/deno"` | deno binary built into Windmill image, should not be changed. Sets DENO_PATH environment variable in frontend and worker container |
| windmill.disableNsjail | bool | `true` | enables/disables nsjail which provide isolation in untrusted environment is disabled by default. Sets DISABLE_NJSAIL environment variable in worker container |
| windmill.disableNuser | bool | `true` | nsjail user . Sets DISABLE_NUSER environment variable in worker container |
| windmill.frontend | object | `{"affinity":{},"annotations":{},"nodeSelector":{},"resources":{},"tolerations":[]}` | frontend configuration |
| windmill.frontend.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.frontend.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.frontend.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.frontend.resources | object | `{}` | Resource limits and requests for the pods |
| windmill.frontend.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.frontendReplicas | int | `2` | replica for the application frontend |
| windmill.image | string | `"main"` |  |
| windmill.lsp | object | `{"affinity":{},"annotations":{},"nodeSelector":{},"resources":{},"tolerations":[]}` | lsp configuration |
| windmill.lsp.affinity | object | `{}` | Affinity rules to apply to the pods |
| windmill.lsp.annotations | object | `{}` | Annotations to apply to the pods |
| windmill.lsp.nodeSelector | object | `{}` | Node selector to use for scheduling the pods |
| windmill.lsp.resources | object | `{}` | Resource limits and requests for the pods |
| windmill.lsp.tolerations | list | `[]` | Tolerations to apply to the pods |
| windmill.lspReplicas | int | `2` | replicas for the lsp containers used by the frontend |
| windmill.nsjailPath | string | `"nsjail"` | nsjail binary. Sets NSJAIL_PATH environment variable in worker container |
| windmill.numWorkers | int | `1` | workers per worker container, default and recommended is 1 to isolate one process per container, sets NUM_WORKER environment variable for worker container.  Frontend container has 0 NUM_WORKERS by default |
| windmill.oauthConfig | string | `"{}\n"` | Oauth configuration for logins and connections. e.g of values   "github": {     "id": "asdfasdf",     "secret": "asdfasdfasdf"    } |
| windmill.pythonPath | string | `"/usr/local/bin/python3"` | python binary built into Windmill image, should not be changed. Sets PYTHON_PATH environment variable in frontend and worker container |
| windmill.rustBacktrace | int | `1` | rust back trace information enabled, sets RUST_BACKTRACE environment variable in frontend and worker container |
| windmill.rustLog | string | `"info"` | rust log level, set to debug for more information etc, sets RUST_LOG environment variable in frontend and worker container |
| windmill.workerReplicas | int | `4` | replicas for the workers, jobs are executed on the workers |
| windmill.workers | object | `{"affinity":{},"annotations":{},"nodeSelector":{},"resources":{},"tolerations":[]}` | workers configuration |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
