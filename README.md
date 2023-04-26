
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
  <a href="#caveatsd">Caveats</a> •  
  <a href="#k8s-tips">Kubernetes Tips</a> •  
</p>

<hr>

## Install

> Have Helm 3 [installed](https://helm.sh/docs/intro/install).

```sh
helm repo add windmill https://windmill-labs.github.io/windmill-helm-charts/
helm install mywindmill windmill/windmill -n windmill --create-namespace
```

## Core Values

```yaml
# windmill root values block
windmill:
  # windmill app image tag
  image: "main"
  # replica for the application frontend
  frontendReplicas: 2
  # replicas for the workers, jobs are executed on the workers
  workerReplicas: 2
  # replicas for the lsp containers used by the frontend
  lspReplicas: 2
  # postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in frontend and worker container
  databaseUrl: postgres://postgres:windmill@windmill-postgresql/windmill?sslmode=disable
  # domain as shown in browser, change to https etc based on your endpoint/ingress configuration, sets BASE_URL environment variable in frontend and worker container
  baseUrl: http://localhost  
  ...

# enable postgres (bitnami) on kubernetes
postgresql:
  enabled: true

# add additional worker groups
workerGroups:
  # workers configuration
  - name: "gpu" 
    ... 

# Configure Ingress
ingress:
  className: ""
  ...

# enable enterprise features
enterprise:
  # -- enable windmill enterprise, requires license key.
  enabled: false
  # -- s3 bucket to use for dependency cache. Sets S3_CACHE_BUCKET environment variable in worker container
  s3CacheBucket: mybucketname
  # -- windmill provided Enterprise license key. Sets LICENSE_KEY environment variable in frontend and worker container.
  licenseKey: 123456F
  # -- use nsjail for sandboxing
  nsjail: false
```

## Full Values

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
| windmill.cookieDomain | string | `""` | domain to use for the cookies. Use it if windmill is hosted on a subdomain and you need to share the cookies with the hub for instance |
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
| windmill.oauthConfig | string | `"{}\n"` | raw oauth config. See <https://docs.windmill.dev/docs/misc/setup_oauth> |
| windmill.oauthSecretName | string | `""` | name of the secret storing the oauthConfig. See <https://docs.windmill.dev/docs/misc/setup_oauth> |
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

## Enterprise features

Enterprise users can use S3 storage for dependency caching for performance.
Cache is two way synced at regular intervals (10 minutes). To use it, the worker
deployment requires access to an S3 bucket. There are several ways to do this:

1. On AWS (and EKS) , you can use a service account with IAM roles attached. See
  [AWS docs](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html) -
  once you have a policy , you can create an account via eksctl for instance
    ```sh
    eksctl create iamserviceaccount --name serviceaccountname --namespace production --cluster windmill-cluster --role-name "iamrolename" \ --attach-policy-arn arn:aws:iam::12312315:policy/bucketpolicy --approve
    ```
2. Mount/attach a credentials file in `/root/.aws/credentials` of the worker
  deployment
3. Add environment variables for the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, via kube secrets.

The sync relies on rclone and uses its methods of authentication to s3 per
[Rclone documentation](https://rclone.org/s3/#authentication)



## Caveats

* Postgres is included for demo purposes, it is a stateful set with a small volume claim applied. If you want to host postgres in k8s, there are better ways, or offload it outside your k8s cluster. Postgres can be disabled entirely in the values.yaml file.
* The postgres user/pass is currently not a secret/encrypted

## Kubernetes Hosting Tips

The included helm chart does not have any ingress configured. The default services are nodeports you can point a load balancer to, or alter the chart to suit. For example, on AWS you might use the AWS ALB controller and configure an ingress like this:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: windmill-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/tags: Environment=dev,Team=test
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/target-group-attributes: stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=600,stickiness.type=app_cookie,stickiness.app_cookie.cookie_name=token,stickiness.app_cookie.duration_seconds=86400
    alb.ingress.kubernetes.io/load-balancer-attributes: idle_timeout.timeout_seconds=600
    alb.ingress.kubernetes.io/group.name: windmill
    alb.ingress.kubernetes.io/group.order: '10'
    alb.ingress.kubernetes.io/certificate-arn: certificatearn
spec:
  ingressClassName: alb
  rules:
    - host:  {{ .Values.windmill.baseDomain }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: windmill-app
                port:
                  number: 8000
```

Again, there are many ways to expose an app and it will depend on the requirements of your environment. Overall, you want the following endpoints accessible included in the chart:

windmill frontend on port 8000
lsp application on port 3001
metrics endpoints on port 8001 for the frontend/app and workers
If you are using Prometheus, you can scrape the windmill-app-metrics service on port 8001 at /metrics endpoint to gather stats about the Windmill application.

A ServiceMonitor is included in the chart for Prometheus Operator users.