#!/usr/bin/env bash

gcloud config set compute/zone us-central1-a
git clone https://github.com/googlecodelabs/orchestrate-with-kubernetes.git
cd orchestrate-with-kubernetes/kubernetes || exit 1
gcloud container clusters create bootcamp --num-nodes 5 --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"

# learn about deployment object
kubectl explain deployment
kubectl explain deployment --recursive # see all fields
kubectl explain deployment.metadata.name

# create pods
kubectl create -f deployments/auth.yaml

# check pods
kubectl get deployments
kubectl get replicasets

# create service
kubectl create -f services/auth.yaml

# create pods and service for hello
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

# expose frontend
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

# hit frontend
kubectl get services frontend
curl -ks https://EXTERNAL-IP
curl -ks https://"$(kubectl get svc frontend -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')"

# scale up
kubectl explain deployment.spec.replicas
kubectl scale deployment hello --replicas=5
kubectl get pods | grep -c hello-

# rolling update
kubectl edit deployment hello
kubectl get replicaset
kubectl rollout history deployment/hello # check revision history

# pause update
kubectl rollout pause deployment/hello
kubectl rollout status deployment/hello

# check pods image version
kubectl get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

# resume update
kubectl rollout resume deployment/hello

# rollback
kubectl rollout undo deployment/hello
kubectl rollout history deployment/hello

# canary deployment (partial deployment)
cat deployments/hello-canary.yaml
kubectl create -f deployments/hello-canary.yaml
kubectl get deployments
curl -ks https://"$(kubectl get svc frontend -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')"/version

# blue-green deployment
# Rolling updates are ideal because they allow you to deploy an application slowly with minimal overhead, minimal performance impact, and minimal downtime.
# There are instances where it is beneficial to modify the load balancers to point to that new version only after it has been fully deployed.
# In this case, blue-green deployments are the way to go.
# Kubernetes achieves this by creating two separate deployments; one for the old "blue" version and one for the new "green" version.
# Use your existing hello deployment for the "blue" version.
# The deployments will be accessed via a Service which will act as the router.
# Once the new "green" version is up and running, you'll switch over to using that version by updating the Service.
kubectl apply -f services/hello-blue.yaml
kubectl create -f deployments/hello-green.yaml
kubectl apply -f services/hello-green.yaml
kubectl apply -f services/hello-blue.yaml # rollback by applying previous config
