#!/usr/bin/env bash

gcloud compute images list \
  --project cos-cloud \
  --no-standard-images

gcloud beta compute instances create-with-container containerized-vm2 \
  --image cos-stable-72-11316-136-0 \
  --image-project cos-cloud \
  --container-image nginx \
  --container-restart-policy always \
  --zone us-central1-a \
  --machine-type n1-standard-1

gcloud compute firewall-rules create allow-containerized-internal \
  --allow tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --network default
