#!/usr/bin/env bash

# default zone and region
gcloud compute project-info describe --project PROJECT_ID

# set env variable
export PROJECT_ID=PROJECT_ID
export ZONE=ZONE

# create compute instance
gcloud compute instances create gcelab2 --machine-type n1-standard-2 --zone $ZONE

# getting started
gcloud -h
gcloud config --help
gcloud config list
gcloud config list --all
gcloud components list

# beta
gcloud components install beta
gcloud beta interactive

# ssh
gcloud compute ssh gcelab2 --zone $ZONE