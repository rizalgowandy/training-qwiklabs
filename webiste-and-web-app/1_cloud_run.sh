#!/usr/bin/env bash

git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices || exit 1
./setup.sh

cd ~/monolith-to-microservices/monolith || exit 1
npm start

gcloud services enable cloudbuild.googleapis.com
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:1.0.0 .

gcloud services enable run.googleapis.com
gcloud run deploy --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:1.0.0 --platform managed

gcloud run services list

gcloud run deploy --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:1.0.0 --platform managed --concurrency 1

gcloud run deploy --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:1.0.0 --platform managed --concurrency 80

cd ~/monolith-to-microservices/react-app/src/pages/Home || exit 1
mv index.js.new index.js
cat ~/monolith-to-microservices/react-app/src/pages/Home/index.js
cd ~/monolith-to-microservices/react-app || exit 1
npm run build:monolith

cd ~/monolith-to-microservices/monolith || exit 1
npm start
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:2.0.0 .

gcloud run deploy --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:2.0.0 --platform managed

gcloud run services describe monolith --platform managed
gcloud beta run services list
gcloud container images delete gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:1.0.0 --quiet
gcloud container images delete gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:2.0.0 --quiet
gcloud builds list | awk 'NR > 1 {print $4}' | while read line; do gsutil rm $line; done

gcloud beta run services delete monolith --platform managed