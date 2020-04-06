#!/usr/bin/env bash

mkdir ~/dmsamples
cd ~/dmsamples || exit 1

git clone https://github.com/GoogleCloudPlatform/deploymentmanager-samples.git

cd ~/dmsamples/deploymentmanager-samples/examples/v2 || exit 1
ls

gcloud deployment-manager deployments create advanced-configuration --config application.yaml

# create firewall allow tcp 8080

gcloud compute forwarding-rules list

sudo apt-get update
sudo apt-get -y install apache2-utils
ab -n 10000 -c 100 http://34.95.86.33:8080/