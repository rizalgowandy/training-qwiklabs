#!/usr/bin/env bash

gcloud config set project "$(gcloud projects list --format='value(PROJECT_ID)' --filter='qwiklabs-gcp')"

INSTANCE_NAME=lamp-1-vm

gcloud beta compute instances create $INSTANCE_NAME \
  --zone=us-central1-a \
  --machine-type=n1-standard-2 \
  --subnet=default \
  --network-tier=PREMIUM \
  --maintenance-policy=MIGRATE \
  --tags=http-server \
  --image=debian-10-buster-v20210316 \
  --image-project=debian-cloud \
  --boot-disk-size=10GB \
  --boot-disk-type=pd-balanced \
  --boot-disk-device-name=$INSTANCE_NAME \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --reservation-affinity=any

gcloud compute firewall-rules create default-allow-http \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server

gcloud compute ssh $INSTANCE_NAME \
  --zone=us-central1-a
sudo apt-get update
sudo apt-get install apache2 php7.0 -y
sudo service apache2 restart
exit

gcloud compute instances describe $INSTANCE_NAME \
  --format='get(networkInterfaces[0].networkIP)' \
  --zone=us-central1-a

gcloud compute ssh $INSTANCE_NAME \
  --zone=us-central1-a
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh
sudo apt-get update
sudo apt-get install stackdriver-agent -y
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh
sudo apt-get update
sudo apt-get install google-fluentd -y
exit