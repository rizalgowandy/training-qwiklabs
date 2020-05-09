#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install git
sudo apt-get install python3-setuptools python3-dev build-essential
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py

python3 --version
pip3 --version

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
cd ~/training-data-analyst/courses/developingapps/python/devenv/ || exit 1
sudo python3 server.py

sudo pip3 install -r requirements.txt
python3 list-gce-instances.py "$PROJECT_ID" --zone="$ZONE"