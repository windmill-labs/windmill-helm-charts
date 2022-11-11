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
* Run ```helm install windmill- windmill/```
* Wait for pods to come up running, takes a couple minutes to pull images and launch ```watch kubectl get pods -n windmill``` 
* After pods launch, run ```minikube service windmill-app```
* Windmill should be available at the URL from the console output. Default credentials: admin@windmill.dev / changeme
* To destroy ```helm delete windmill```

Alter the values and inputs to suit your environment. The services included are Nodeports for ease of testing on Minikub.

