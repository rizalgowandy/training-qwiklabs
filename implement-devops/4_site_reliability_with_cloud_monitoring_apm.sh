#!/usr/bin/env bash

gcloud config set compute/zone us-west1-b
export PROJECT_ID=$(gcloud info --format='value(config.project)')
gcloud container clusters list

gcloud container clusters get-credentials shop-cluster --zone us-west1-b
kubectl get nodes

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/blogs/microservices-demo-1 ~/microservices-demo-1
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/v0.36.0/skaffold-linux-amd64 && chmod +x skaffold && sudo mv skaffold /usr/local/bin
cd microservices-demo-1 || exit 1
skaffold run
kubectl get pods

export EXTERNAL_IP=$(kubectl get service frontend-external | awk 'BEGIN { cnt=0; } { cnt+=1; if (cnt > 1) print $4; }')
curl -o /dev/null -s -w "%{http_code}\n"  http://$EXTERNAL_IP
./setup_csr.sh