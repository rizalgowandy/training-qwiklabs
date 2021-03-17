#!/usr/bin/env bash

gcloud config set project "$(gcloud projects list --format='value(PROJECT_ID)' --filter='qwiklabs-gcp')"

gcloud compute networks create managementnet \
  --subnet-mode=custom \
  --mtu=1460 \
  --bgp-routing-mode=regional
gcloud compute networks subnets create managementsubnet-us \
  --range=10.130.0.0/20 \
  --network=managementnet \
  --region=us-central1

gcloud compute networks create privatenet --subnet-mode=custom
gcloud compute networks subnets create privatesubnet-us \
  --network=privatenet \
  --region=us-central1 \
  --range=172.16.0.0/24
gcloud compute networks subnets create privatesubnet-eu \
  --network=privatenet \
  --region=europe-west4 \
  --range=172.20.0.0/20

gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
  --direction=INGRESS \
  --priority=1000 \
  --network=managementnet \
  --action=ALLOW \
  --rules=tcp:22,tcp:3389,icmp \
  --source-ranges=0.0.0.0/0

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
  --direction=INGRESS \
  --priority=1000 \
  --network=privatenet \
  --action=ALLOW \
  --rules=icmp,tcp:22,tcp:3389 \
  --source-ranges=0.0.0.0/0

gcloud beta compute instances create managementnet-us-vm \
  --zone=us-central1-c \
  --machine-type=f1-micro \
  --subnet=managementsubnet-us \
  --network-tier=PREMIUM \
  --maintenance-policy=MIGRATE \
  --image=debian-10-buster-v20210316 \
  --image-project=debian-cloud \
  --boot-disk-size=10GB \
  --boot-disk-type=pd-balanced \
  --boot-disk-device-name=managementnet-us-vm \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --reservation-affinity=any

gcloud compute instances create privatenet-us-vm \
  --zone=us-central1-c \
  --machine-type=n1-standard-1 \
  --subnet=privatesubnet-us

gcloud beta compute instances create vm-appliance \
  --zone=us-central1-c \
  --machine-type=n1-standard-4 \
  --network-interface subnet=privatesubnet-us \
  --network-interface subnet=managementsubnet-us \
  --network-interface subnet=mynetwork \
  --image=debian-10-buster-v20210316 \
  --image-project=debian-cloud \
  --boot-disk-size=10GB \
  --boot-disk-type=pd-balanced \
  --boot-disk-device-name=vm-appliance \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --reservation-affinity=any
