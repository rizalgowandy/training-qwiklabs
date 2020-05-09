#!/usr/bin/env bash

virtualenv -p python3 vrenv
source vrenv/bin/activate

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
cd ~/training-data-analyst/courses/developingapps/python/datastore/start || exit 1
export GCLOUD_PROJECT=$DEVSHELL_PROJECT_ID

pip install -r requirements.txt
python run_server.py

