#!/usr/bin/env bash

gcloud config set compute/zone us-east1-d
git clone https://github.com/GoogleCloudPlatform/continuous-deployment-on-kubernetes.git
cd continuous-deployment-on-kubernetes || exit 1

# provisioning jenkins
gcloud container clusters create jenkins-cd \
  --num-nodes 2 \
  --machine-type n1-standard-2 \
  --scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform"
gcloud container clusters list
gcloud container clusters get-credentials jenkins-cd --zone us-east1-d
kubectl cluster-info

# install helm
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.14.1-linux-amd64.tar.gz
tar zxfv helm-v2.14.1-linux-amd64.tar.gz
cp linux-amd64/helm .
# Add yourself as a cluster administrator in the cluster's RBAC so that you can give Jenkins permissions in the cluster:
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user="$(gcloud config get-value account)"
# Grant Tiller, the server side of Helm, the cluster-admin role in your cluster:
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
# initialize helm
./helm init --service-account=tiller
./helm update
./helm version

# install jenkins
./helm install -n cd stable/jenkins -f jenkins/values.yaml --version 1.2.2 --wait
kubectl get pods
kubectl create clusterrolebinding jenkins-deploy --clusterrole=cluster-admin --serviceaccount=default:cd-jenkins
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward "$POD_NAME" 8080:8080 >>/dev/null &
kubectl get svc

# print password
kubectl get secret cd-jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode;echo

# deploying app
cd sample-app || exit 1
kubectl create ns production
kubectl apply -f k8s/production -n production
kubectl apply -f k8s/canary -n production
kubectl apply -f k8s/services -n production
kubectl scale deployment gceme-frontend-production -n production --replicas 4
kubectl get pods -n production -l app=gceme -l role=frontend
kubectl get pods -n production -l app=gceme -l role=backend
kubectl get service gceme-frontend -n production
export FRONTEND_SERVICE_IP=$(kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)

# create jenkins pipeline
gcloud source repos create default
git init
git config credential.helper gcloud.sh
git remote add origin https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/default
git config --global user.email "rizal.gow@gmail.com"
git config --global user.name "Rizal Widyarta Gowandy"
git add .
git commit -m "Initial commit"
git push origin master

# add credential on jenkins, create new item
kubectl proxy &
curl http://localhost:8001/api/v1/namespaces/new-feature/services/gceme-frontend:80/proxy/version

export FRONTEND_SERVICE_IP=$(kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)
while true; do curl http://"$FRONTEND_SERVICE_IP"/version; sleep 1; done
kubectl get service gceme-frontend -n production