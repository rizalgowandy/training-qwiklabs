#!/usr/bin/env bash

git clone https://github.com/googleapis/nodejs-dlp.git
export GCLOUD_PROJECT=YOUR_PROJECT_ID

npm install --save @google-cloud/dlp
npm install yargs

cd nodejs-dlp/samples || exit 1
node inspect.js string "My email address is joe@example.com."

