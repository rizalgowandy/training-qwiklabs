#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/appengine-guestbook-python
cd appengine-guestbook-python/ || exit 1
gcloud app create
gcloud app deploy --version 1
gcloud datastore indexes create index.yaml