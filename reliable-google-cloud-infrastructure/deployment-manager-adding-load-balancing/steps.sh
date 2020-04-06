#!/usr/bin/env bash

mkdir ~/archdp
cd ~/archdp || exit 1

# wget https://storage.googleapis.com/cloud-training/archdp/archdp-echo.tar.gz
gsutil cp gs://cloud-training/archdp/archdp-echo.tar.gz .
tar -xzvf archdp-echo.tar.gz

cd ~/archdp/echo || exit 1
python setup.py sdist
cd dist || exit 1
ls

export MY_BUCKET=qwiklabs-gcp-00-01bc5fee417d
gsutil -h 'Content-Type: application/gzip' -h 'Cache-Control:private' cp -a public-read echo-0.0.1.tar.gz gs://$MY_BUCKET
gsutil ls -L gs://$MY_BUCKET/echo-0.0.1.tar.gz

cd ~/archdp/deployment-manager-examples || exit 1
ls

gcloud deployment-manager deployments create echo-lb-service --config http-lb.yaml

# create firewall to allow healthcheck
# get forwarding-rules
gcloud compute forwarding ip

# create ab instance
sudo apt-get update
sudo apt-get -y install apache2-utils
ab -n 1000 -c 100 http://<your forwarding IP>/