#!/usr/bin/env bash

cd ~/echolb/echo || exit 1
python3 setup.py sdist
cd dist || exit 1
ls

export MY_BUCKET=qwiklabs-gcp-00-2a3b5067111c
gsutil -h 'Content-Type: application/gzip' -h 'Cache-Control:private' cp -a public-read echo-0.0.1.tar.gz gs://$MY_BUCKET
gsutil ls -L gs://$MY_BUCKET/echo-0.0.1.tar.gz

# create vm instance
sudo apt-get update
sudo apt-get -y install python3-pip
sudo python3 -m pip install --upgrade pip

sudo python3 -m pip install http://storage.googleapis.com/$MY_BUCKET/echo-0.0.1.tar.gz
sudo gunicorn -b 0.0.0.0:80 -w 4 echo:app

cd ~/echolb/deployment-manager-examples || exit 1
gcloud deployment-manager deployments create echo-service --config config.yaml
