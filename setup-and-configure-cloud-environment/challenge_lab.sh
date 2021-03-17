#!/usr/bin/env bash

gcloud compute instances create nucleus-jumphost \
        --zone="us-east1-b" \
        --machine-type="f1-micro" \
        --boot-disk-size=10GB

echo "======================="
echo ">>>> DONE: Task 1: Create a project jump host instance"
echo "======================="


gcloud config set compute/zone us-east1-b
gcloud container clusters create nucleus-jumphost-webserver1
gcloud container clusters get-credentials nucleus-jumphost-webserver1
kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:2.0
kubectl expose deployment hello-app --type=LoadBalancer --port 8080
kubectl get service

echo "======================="
echo ">>>> DONE: Task 2: Create a Kubernetes service cluster"
echo "======================="

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
gcloud compute instance-templates create nginx-template \
--metadata-from-file startup-script=startup.sh

gcloud compute target-pools create nginx-pool \
    --region us-east1

gcloud compute instance-groups managed create nginx-group \
    --base-instance-name nginx \
    --size 2 \
    --template nginx-template \
    --target-pool nginx-pool

gcloud compute firewall-rules create www-firewall --allow tcp:80
gcloud compute forwarding-rules create nginx-lb \
    --region us-east1 \
    --ports=80 \
    --target-pool nginx-pool

gcloud compute http-health-checks create http-basic-check
gcloud compute instance-groups managed set-named-ports nginx-group \
    --named-ports http:80

gcloud compute backend-services create nginx-backend \
    --protocol HTTP --http-health-checks http-basic-check --global
gcloud compute backend-services add-backend nginx-backend \
    --instance-group nginx-group \
    --instance-group-zone us-east1-b \
    --global

gcloud compute url-maps create web-map \
    --default-service nginx-backend
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map

gcloud compute forwarding-rules create http-content-rule \
    --global \
    --target-http-proxy http-lb-proxy \
    --ports 80

echo "======================="
echo ">>>> DONE: Task 3: Set up an HTTP load balancer"
echo "======================="
