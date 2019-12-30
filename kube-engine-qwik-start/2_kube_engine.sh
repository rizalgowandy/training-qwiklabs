#!/usr/bin/env bash

gcloud config set compute/zone us-central1-a
gcloud container clusters create CLUSTER-NAME
gcloud container clusters get-credentials CLUSTER-NAME

kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment hello-server --type=LoadBalancer --port 8080

kubectl get service

gcloud container clusters delete CLUSTER-NAME
