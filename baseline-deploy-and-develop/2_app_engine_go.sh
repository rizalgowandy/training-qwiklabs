#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/golang-samples.git
cd golang-samples/appengine/go11x/helloworld || exit 1

# deploy app
gcloud components install app-engine-go
gcloud app deploy

# view app
gcloud app browse
