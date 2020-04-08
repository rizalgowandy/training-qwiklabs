#!/usr/bin/env bash

export PROJECT_ID=qwiklabs-gcp-00-7977aa4f42bb
docker build -t gcr.io/${PROJECT_ID}/echo-app:v2 .
docker push gcr.io/${PROJECT_ID}/echo-app:v2
gcloud container clusters get-credentials echo-cluster --zone=us-central1-a
kubectl set image deployment echo-web echo-web=gcr.io/${PROJECT_ID}/echo-app:v2
kubectl set image deployment
kubectl scale deployment echo-web --replicas=2

https://cloud.google.com/kubernetes-engine/docs/how-to/updating-apps

# my solution
gsutil cp gs://qwiklabs-gcp-00-7977aa4f42bb/resources-echo-web-v2.tar.gz .
tar -zxvf resources-echo-web-v2.tar.gz
docker build -t echo-app:v2 .
docker tag echo-app:v2 gcr.io/qwiklabs-gcp-00-7977aa4f42bb/echo-app:v2
docker push gcr.io/qwiklabs-gcp-00-7977aa4f42bb/echo-app:v2

kubectl create deployment echo-web --image=gcr.io/qwiklabs-gcp-00-7977aa4f42bb/echo-app:v2 --port=8000
kubectl scale deployment echo-web --replicas=2
kubectl expose deployment echo-web --type=LoadBalancer --port=80 --target-port=8000