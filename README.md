
- [Windmill Helm Chart](#windmill-helm-chart)
  - [Deploying demo on minikube](#deploying-demo-on-minikube)
    - [Deploy via Helm repo](#deploy-via-helm-repo)
    - [Direct from cloned repo](#direct-from-cloned-repo)
  - [Kubernetes hosting tips](#kubernetes-hosting-tips)
    - [Enterprise features](#enterprise-features)
- [Values](#values)

# Windmill Helm Chart

Example chart for deploying Windmill and testing it on Kubernetes or Minikube.


Caveats:

* Postgres is included for demo purposes, it is a stateful set with a small 10GB volume claim applied.  If you want to host postgres in k8s, there are better ways, or offload it outside your k8s cluster.  Postgres can be disabled entirely in the values.yaml file.
* The postgres user/pass is currently not a secret/encrypted

## Deploying demo on minikube

Tested with minikube on WSL2 in Windows 10.

### Deploy via Helm repo

* Have Helm 3 installed, this chart was created with v3.94 - https://helm.sh/docs/intro/install/ . Depending on your K8s version you may need Helm 3.8 or below.
* Start minikube / make sure your cluster is running - ```minikube start```
* Add the Helm repo ```helm repo add windmill https://windmill-labs.github.io/windmill-helm-charts/```
* Run ```helm install mywindmill windmill/windmill -n windmill --create-namespace```
* Wait for pods to come up running, takes a couple minutes to pull images and launch ```watch kubectl get pods -n windmill``` 
* After pods launch, run ```minikube service windmill-app```
* Windmill should be available at the URL from the console output. Default credentials: admin@windmill.dev / changeme
* To destroy ```helm delete windmill```

Alter the values and inputs to suit your environment. The services included are Nodeports for ease of testing on Minikub.

### Direct from cloned repo

You can install from a copy of this repository directly. Helpful if you plan to fork it/copy it for updating in your own environment. 

* Clone repo locally, navigate to the charts directory
* Copy the values.yaml file somewhere else and update defaults if desired
* Have Helm 3 installed, this chart was created with v3.94 - https://helm.sh/docs/intro/install/ . Depending on your K8s version you may need Helm 3.8 or below.
* Start minikube - ```minikube start```
* Run ```helm install windmill windmill/ -f myvalues_file.yaml -n windmill --create-namespace```
* Wait for pods to come up running, takes a couple minutes to pull images and launch ```watch kubectl get pods -n windmill``` 
* After pods launch, run ```minikube service windmill-app```
* Windmill should be available at the URL from the console output. Default credentials: admin@windmill.dev / changeme
* To destroy ```helm delete windmill```

Alter the values and inputs to suit your environment. The services included are Nodeports for ease of testing on Minikub.

## Kubernetes hosting tips

The included helm chart does not have any ingress configured.  The default services are nodeports you can point a load balancer to, or alter the chart to suit. For example, on AWS you might use the AWS ALB controller and configure an ingress like this:

```
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

* windmill frontend on port 8000
* lsp application on port 3001
* metrics endpoints on port 8001 for the frontend/app and workers

If you are using Prometheus, you can scrape the windmill-app-metrics service on port 8001 at /metrics endpoint to gather stats about the Windmill application.


### Enterprise features

Enterprise users can use S3 storage for dependency caching for performance.  Cache is two way synced at regular intervals (10 minutes).  To use it, the worker deployment requires access to an S3 bucket.  There are several ways to do this:

* On AWS (and EKS) , you can use a service account with IAM roles attached. See [AWS docs](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html) - once you have a policy , you can create an account via eksctl for instance ```eksctl create iamserviceaccount --name serviceaccountname --namespace production --cluster windmill-cluster --role-name "iamrolename" \
    --attach-policy-arn arn:aws:iam::12312315:policy/bucketpolicy --approve```
* Mount/attach a credentials file in /root/.aws/credentials of the worker deployment
* Add environment variables for the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, via kube secrets.  

The sync relies on rclone and uses its methods of authentication to s3 per [Rclone documentation](https://rclone.org/s3/#authentication)


# Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| enterprise.enabled | bool | `false` | enable Windmill Enterprise , requires license key.  |
| enterprise.licenseKey | string | `"123456F"` | Windmill provided Enterprise license key. Sets LICENSE_KEY environment variable in frontend and worker container. |
| enterprise.s3CacheBucket | string | `"mybucketname"` | S3 bucket to use for dependency cache. Sets S3_CACHE_BUCKET environment variable in worker container |
| postgres.dbName | string | `"windmill"` | database name for postgres demo container |
| postgres.enabled | bool | `true` | enabled included Postgres container for demo purposes only |
| postgres.password | string | `"changeme"` | password for postgres demo container |
| windmill.baseInternalUrl | string | `"http://windmill-app:8000"` | used internally by the app, should match the service for the frontend deployment, sets BASE_INTERNAL_URL environment variable in frontend and worker container |
| windmill.baseUrl | string | `"http://localhost"` | domain as shown in browser, change to https etc based on your endpoint/ingress configuration, sets BASE_URL environment variable in frontend and worker container |
| windmill.databaseUrl | string | `"postgres://postgres:changeme@postgres/windmill?sslmode=disable"` | Postgres URI, pods will crashloop if database is unreachable, sets DATABASE_URL environment variable in frontend and worker container |
| windmill.denoPath | string | `"/usr/bin/deno"` | deno binary built into Windmill image, should not be changed. Sets DENO_PATH environment variable in frontend and worker container |
| windmill.disableNsjail | bool | `true` | enables/disables nsjail which provide isolation in untrusted environment is disabled by default. Sets DISABLE_NJSAIL environment variable in worker container |
| windmill.disableNuser | bool | `true` | nsjail user . Sets DISABLE_NUSER environment variable in worker container |
| windmill.frontendReplicas | int | `3` | replica for the application frontend  |
| windmill.lspReplicas | int | `2` | replicas for the lsp containers used by the frontend |
| windmill.nsjailPath | string | `"nsjail"` | nsjail binary. Sets NSJAIL_PATH environment variable in worker container |
| windmill.numWorkers | int | `1` | workers per worker container, default and recommended is 1 to isolate one process per container, sets NUM_WORKER environment variable for worker container.  Frontend container has 0 NUM_WORKERS by default |
| windmill.oauthConfig | string | `"{\n  \"github\": {\n      \"id\": \"asdfasdf\",\n      \"secret\": \"asdfasdfasdf\"\n  }\n }\n"` | Oauth configuration for logins etc |
| windmill.pythonPath | string | `"/usr/local/bin/python3"` | python binary built into Windmill image, should not be changed. Sets PYTHON_PATH environment variable in frontend and worker container |
| windmill.rustBacktrace | int | `1` | rust back trace information enabled, sets RUST_BACKTRACE environment variable in frontend and worker container |
| windmill.rustLog | string | `"info"` | rust log level, set to debug for more information etc, sets RUST_LOG environment variable in frontend and worker container |
| windmill.workerReplicas | int | `3` | replicas for the workers, jobs are executed on the workers |

----------------------------------------------

