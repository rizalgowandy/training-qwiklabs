#!/usr/bin/env bash

wget https://storage.googleapis.com/spls/gsp269/gke-tls-lab-v0.13.tar.gz
tar zxfv gke-tls-lab-v0.13.tar.gz
cd gke-tls-lab || exit 1

gcloud compute addresses create endpoints-ip --region us-central1
gcloud compute addresses list

gcloud endpoints services deploy openapi.yaml
gcloud container clusters create cl-cluster --zone us-central1-f
gcloud container clusters get-credentials cl-cluster --zone us-central1-f
kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole cluster-admin --user $(gcloud config get-value account)

curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller-binding \
    --clusterrole=cluster-admin \
    --serviceaccount kube-system:tiller
helm init --service-account tiller
helm repo update

gcloud compute addresses list
helm install stable/nginx-ingress --set controller.service.loadBalancerIP="34.72.251.229",rbac.create=true

kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.13.0/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  --name cert-manager \
  --namespace cert-manager \
  --version v0.13.0 \
  jetstack/cert-manager

kubectl get pods --namespace cert-manager
export EMAIL=qwiklabs-gcp-01-0d50e5090db0
cat letsencrypt-issuer.yaml | sed -e "s/email: ''/email: $EMAIL/g" | kubectl apply -f-

kubectl apply -f ingress-tls.yaml
kubectl describe ingress esp-ingress