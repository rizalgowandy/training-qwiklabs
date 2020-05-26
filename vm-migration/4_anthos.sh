#!/usr/bin/env bash

gcloud beta compute  instances create   source-vm  --zone=us-central1-a --machine-type=n1-standard-1   --subnet=default --scopes="cloud-platform"   --tags=http-server,https-server --image=ubuntu-minimal-1604-xenial-v20200317   --image-project=ubuntu-os-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard   --boot-disk-device-name=source-vm --metadata startup-script='#! /bin/bash
# Installs apache and a custom homepage
sudo su -
apt-get update
apt-get install -y apache2
cat <<EOF > /var/www/html/index.html
<html><body><h1>Hello World</h1>
<p>This page was created from a simple start up script!</p>
</body></html>
EOF'

gcloud compute firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW   --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

gcloud container clusters create target-cluster --scopes="cloud-platform"   --zone=us-central1-c --machine-type n1-standard-4   --image-type ubuntu --num-nodes 3 --enable-stackdriver-kubernetes

gcloud container clusters get-credentials target-cluster   --zone us-central1-c
migctl setup install
migctl doctor

migctl source create ce migration-source --project $DEVSHELL_PROJECT_ID --zone us-central1-a
migctl migration create my-migration --source migration-source   --vm-id source-vm --intent Image

migctl migration generate-artifacts my-migration
migctl migration status my-migration

migctl migration status my-migration -v
migctl migration get-artifacts my-migration

kubectl apply -f deployment_spec.yaml
kubectl get service