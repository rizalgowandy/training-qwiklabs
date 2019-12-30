#!/usr/bin/env bash

sudo su
apt-get update
apt-get install nginx -y
ps auwx | grep nginx

# create instance
gcloud compute instances create gcelab2 --machine-type n1-standard-2 --zone your_zone

# create global config
gcloud config set compute/zone ...
gcloud config set compute/region ...

# ssh
gcloud compute ssh gcelab2 --zone YOUR_ZONE