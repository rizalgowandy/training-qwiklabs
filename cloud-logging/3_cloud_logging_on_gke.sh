#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/gke-logging-sinks-demo
cd gke-logging-sinks-demo || exit 1
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# /gke-logging-sinks-demo/terraform/provider.tf
#provider "google" {
#  project = var.project
#  version = "~> 2.19.0"
#}

# /gke-logging-sinks-demo/terraform/main.tf.
# Change the filter's resource.type from container to k8s_container.
# line 106 and 116

make create