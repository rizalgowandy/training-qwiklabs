#!/usr/bin/env bash

gsutil cp -r gs://spls/gsp163/* .
unzip apigee-taw-20180328T192944Z-001.zip

cd apigee-taw/apigee-utils || exit 1
python import_datastore_categories.py
python import_datastore_publishers.py

cd || exit 1
cd apigee-taw/module-1 || exit 1
gcloud app deploy
