#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
cd ~/training-data-analyst/courses/developingapps/python/pubsub-languageapi-spanner/start || exit 1
. prepare_web_environment.sh
python run_server.py

# second terminal
cd ~/training-data-analyst/courses/developingapps/python/pubsub-languageapi-spanner/start || exit 1
. run_worker.sh

# create pubsub topic feedback
gcloud pubsub subscriptions create worker-subscription --topic feedback
gcloud pubsub topics publish feedback --message "Hello World"
gcloud beta pubsub subscriptions pull worker-subscription --auto-ack

# api.py
# pubsub.py
# worker.py
# languageapi.py
# spanner.py
