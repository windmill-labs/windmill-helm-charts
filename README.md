# Windmill Helm Chart

Example chart for deploying Windmill and testing it on Kubernetes or Minikube.


Caveats:

* Postgres is included for demo purposes, it is a stateful set with a small 10GB volume claim applied.  If you want to host postgres in k8s, there are better ways, or offload it outside your k8s cluster.  Postgres can be disabled entirely in the values.yaml file.
* The postgres user/pass is currently not a secret/encrypted

## Deploying demo on minikube

Tested with minikube on WSL2 in Windows 10.

* Clone repo locally, navigate to the charts directory
* Have Helm 3 installed, this chart was created with v3.94 - https://helm.sh/docs/intro/install/ . Depending on your K8s version you may need Helm 3.8 or below.
* Start minikube - ```minikube start```
* Run ```helm install windmill windmill/```
* Wait for pods to come up running, takes a couple minutes to pull images and launch ```watch kubectl get pods -n windmill``` 
* After pods launch, run ```minikube service windmill-app```
* Windmill should be available at the URL from the console output. Default credentials: admin@windmill.dev / changeme
* To destroy ```helm delete windmill```

Alter the values and inputs to suit your environment. The services included are Nodeports for ease of testing on Minikub.

### Enterprise features

Enterprise users can use S3 storage for dependency caching for performance.  Cache is two way synced at regular intervals (10 minutes).  To use it, the worker deployment requires access to an S3 bucket.  There are several ways to do this:

* On AWS (and EKS) , you can use a service account with IAM roles attached. See [AWS docs](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html) - once you have a policy , you can create an account via eksctl for instance ```eksctl create iamserviceaccount --name serviceaccountname --namespace production --cluster windmill-cluster --role-name "iamrolename" \
    --attach-policy-arn arn:aws:iam::976079455550:policy/bucketpolicy --approve```
* Mount/attach a credentials file in /root/.aws/credentials of the worker deployment
* Add environment variables for the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, via kube secrets.  

The sync relies on rclone and uses its methods of authentication to s3 per [Rclone documentation](https://rclone.org/s3/#authentication)


# Values


| Key | Type | Default | Description |
|-----|------|---------|-------------|
| enterprise.enabled | bool | `false` | enable Windmill Enterprise , requires license key |
| enterprise.licenseKey | string | `"123456F"` | Windmill provided Enterprise license key |
| enterprise.s3CacheBucket | string | `"mybucketname"` | S3 bucket to use for dependency cache |
| postgres.dbName | string | `"windmill"` | database name for postgres demo container |
| postgres.enabled | bool | `true` | enabled included Postgres container for demo purposes only |
| postgres.password | string | `"changeme"` | password for postgres demo container |
| windmill.baseInternalUrl | string | `"http://windmill-app:8000"` | used internally by the app, should match the service for the frontend deployment |
| windmill.baseUrl | string | `"http://localhost"` | domain as shown in browser, change to https etc based on your endpoint/ingress configuration |
| windmill.databaseUrl | string | `"postgres://postgres:changeme@postgres/windmill?sslmode=disable"` | Postgres URI, pods will crashloop if database is unreachable |
| windmill.denoPath | string | `"/usr/bin/deno"` | deno binary built into Windmill image, should not be changed  |
| windmill.disableNsjail | bool | `true` | enables/disables nsjail which provide isolation in untrusted environment is disabled by default.  |
| windmill.disableNuser | bool | `true` | nsjail user |
| windmill.frontendReplicas | int | `3` | replica for the application frontend  |
| windmill.lspReplicas | int | `2` | replicas for the lsp containers used by the frontend |
| windmill.nsjailPath | string | `"nsjail"` | nsjail binary |
| windmill.numWorkers | int | `1` | workers per worker container, default and recommended is 1 to isolate one process per container |
| windmill.oauthConfig | string | `"{\n  \"github\": {\n      \"id\": \"asdfasdf\",\n      \"secret\": \"asdfasdfasdf\"\n  }\n }\n"` | Oauth configuration for logins etc |
| windmill.pythonPath | string | `"/usr/local/bin/python3"` | python binary built into Windmill image, should not be changed  |
| windmill.rustBacktrace | int | `1` | rust back trace information enabled |
| windmill.rustLog | string | `"info"` | rust log level, set to debug for more information etc |
| windmill.workerReplicas | int | `3` | replicas for the workers, jobs are executed on the workers |
