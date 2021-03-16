#!/usr/bin/env bash

gcloud config set project "$(gcloud projects list --format='value(PROJECT_ID)' --filter='qwiklabs-gcp')"
git clone https://github.com/rosera/pet-theory.git

# 1. Firestore Database Create
# Go to Firestore.

# 2. Firestore Database Populate
cd pet-theory/lab06/firebase-import-csv/solution || exit 1
npm install
node index.js netflix_titles_original.csv

# 3. Cloud Build Rest API Staging
cd ~/pet-theory/lab06/firebase-rest-api/solution-01 || exit 1
npm install
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1
gcloud beta run deploy netflix-dataset-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# 4. Cloud Build Rest API Production
cd ~/pet-theory/lab06/firebase-rest-api/solution-02 || exit 1
npm install
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.2
gcloud beta run deploy netflix-dataset-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.2 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
# go to cloud run and click netflix-dataset-service then copy the url
SERVICE_URL=https://netflix-dataset-service-isyst7y65q-uc.a.run.app/
curl -X GET $SERVICE_URL/2019

# 5. Cloud Build Frontend Staging
cd ~/pet-theory/lab06/firebase-frontend/public || exit 1
nano app.js # comment line 4 and uncomment line 5, insert your netflix-dataset-service url
npm install
cd ~/pet-theory/lab06/firebase-frontend || exit 1
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1
gcloud beta run deploy frontend-staging-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# 6. Cloud Build Frontend Production
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-production:0.1
gcloud beta run deploy frontend-production-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-production:0.1 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
