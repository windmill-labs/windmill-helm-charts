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