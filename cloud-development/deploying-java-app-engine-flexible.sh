#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
cd ~/training-data-analyst/courses/developingapps/java/appengine/start || exit 1
nano prepare_environment.sh

gcloud functions deploy process-feedback --runtime nodejs8 --trigger-topic feedback --source ./function --stage-bucket $GCLOUD_BUCKET --entry-point subscribe
. prepare_environment.sh

# src/main/appengine/app.yaml
#runtime: java
#env: flex
#runtime_config:
#  jdk: openjdk8
#handlers:
#- url: /.*
#  script: this field is required, but ignored
#manual_scaling:
#  instances: 1
#resources:
#  cpu: 1
#  memory_gb: 3.75
#  disk_size_gb: 10
#env_variables:
#  GCLOUD_BUCKET: [GCLOUD_BUCKET]

mvn clean compile appengine:deploy
mvn clean compile appengine:deploy \
-Dapp.deploy.stopPreviousVersion=False \
-Dapp.deploy.promote=False