#!/usr/bin/env bash

gcloud pubsub topics create new-lab-report
gcloud services enable run.googleapis.com

git clone https://github.com/rosera/pet-theory.git
cd pet-theory/lab05/lab-service || exit 1
npm install express
npm install body-parser
npm install @google-cloud/pubsub

#  "scripts": {
#    "start": "node index.js",
#    "test": "echo \"Error: no test specified\" && exit 1"
#  },

# index.js
#const {PubSub} = require('@google-cloud/pubsub');
#const pubsub = new PubSub();
#const express = require('express');
#const app = express();
#const bodyParser = require('body-parser');
#app.use(bodyParser.json());
#const port = process.env.PORT || 8080;
#
#app.listen(port, () => {
#  console.log('Listening on port', port);
#});
#
#app.post('/', async (req, res) => {
#  try {
#    const labReport = req.body;
#    await publishPubSubMessage(labReport);
#    res.status(204).send();
#  }
#  catch (ex) {
#    console.log(ex);
#    res.status(500).send(ex);
#  }
#})
#
#async function publishPubSubMessage(labReport) {
#  const buffer = Buffer.from(JSON.stringify(labReport));
#  await pubsub.topic('new-lab-report').publish(buffer);
#}

# Dockerfile
#FROM node:10
#WORKDIR /usr/src/app
#COPY package.json package*.json ./
#RUN npm install --only=production
#COPY . .
#CMD [ "npm", "start" ]

gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/lab-report-service
gcloud run deploy lab-report-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/lab-report-service \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

chmod u+x deploy.sh
./deploy.sh

export LAB_REPORT_SERVICE_URL=$(gcloud run services describe lab-report-service --platform managed --region us-central1 --format="value(status.address.url)")
echo $LAB_REPORT_SERVICE_URL
curl -X POST \
  -H "Content-Type: application/json" \
  -d "{\"id\": 12}" \
  $LAB_REPORT_SERVICE_URL &
curl -X POST \
  -H "Content-Type: application/json" \
  -d "{\"id\": 34}" \
  $LAB_REPORT_SERVICE_URL &
curl -X POST \
  -H "Content-Type: application/json" \
  -d "{\"id\": 56}" \
  $LAB_REPORT_SERVICE_URL &
chmod u+x post-reports.sh
./post-reports.sh

cd ~/pet-theory/lab05/email-service || exit 1
npm install express
npm install body-parser

#  "scripts": {
#    "start": "node index.js",
#    "test": "echo \"Error: no test specified\" && exit 1"
#  },

# index.js
#const express = require('express');
#const app = express();
#const bodyParser = require('body-parser');
#app.use(bodyParser.json());
#
#const port = process.env.PORT || 8080;
#app.listen(port, () => {
#  console.log('Listening on port', port);
#});
#
#app.post('/', async (req, res) => {
#  const labReport = decodeBase64Json(req.body.message.data);
#  try {
#    console.log(`Email Service: Report ${labReport.id} trying...`);
#    sendEmail();
#    console.log(`Email Service: Report ${labReport.id} success :-)`);
#    res.status(204).send();
#  }
#  catch (ex) {
#    console.log(`Email Service: Report ${labReport.id} failure: ${ex}`);
#    res.status(500).send();
#  }
#})
#
#function decodeBase64Json(data) {
#  return JSON.parse(Buffer.from(data, 'base64').toString());
#}
#
#function sendEmail() {
#  console.log('Sending email');
#}

# Dockerfile
#FROM node:10
#WORKDIR /usr/src/app
#COPY package.json package*.json ./
#RUN npm install --only=production
#COPY . .
#CMD [ "npm", "start" ]

gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/email-service

gcloud run deploy email-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/email-service \
  --platform managed \
  --region us-central1 \
  --no-allow-unauthenticated

chmod u+x deploy.sh
./deploy.sh

gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker"
gcloud run services add-iam-policy-binding email-service --member=serviceAccount:pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com --role=roles/run.invoker --region us-central1 --platform managed
PROJECT_NUMBER=$(gcloud projects list --filter="qwiklabs-gcp" --format='value(PROJECT_NUMBER)')
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com --role=roles/iam.serviceAccountTokenCreator
EMAIL_SERVICE_URL=$(gcloud run services describe email-service --platform managed --region us-central1 --format="value(status.address.url)")
echo $EMAIL_SERVICE_URL
gcloud pubsub subscriptions create email-service-sub --topic new-lab-report --push-endpoint=$EMAIL_SERVICE_URL --push-auth-service-account=pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com

~/pet-theory/lab05/lab-service/post-reports.sh

cd ~/pet-theory/lab05/sms-service || exit 1
npm install express
npm install body-parser

#...
#
#"scripts": {
#    "start": "node index.js",
#    "test": "echo \"Error: no test specified\" && exit 1"
#  },
#
#...

# index.js
#const express = require('express');
#const app = express();
#const bodyParser = require('body-parser');
#app.use(bodyParser.json());
#
#const port = process.env.PORT || 8080;
#app.listen(port, () => {
#  console.log('Listening on port', port);
#});
#
#app.post('/', async (req, res) => {
#  const labReport = decodeBase64Json(req.body.message.data);
#  try {
#    console.log(`SMS Service: Report ${labReport.id} trying...`);
#    sendSms();
#
#    console.log(`SMS Service: Report ${labReport.id} success :-)`);
#    res.status(204).send();
#  }
#  catch (ex) {
#    console.log(`SMS Service: Report ${labReport.id} failure: ${ex}`);
#    res.status(500).send();
#  }
#})
#
#function decodeBase64Json(data) {
#  return JSON.parse(Buffer.from(data, 'base64').toString());
#}
#
#function sendSms() {
#  console.log('Sending SMS');
#}

# Dockerfile
#FROM node:10
#WORKDIR /usr/src/app
#COPY package.json package*.json ./
#RUN npm install --only=production
#COPY . .
#CMD [ "npm", "start" ]

gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/sms-service

gcloud run deploy sms-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/sms-service \
  --platform managed \
  --region us-central1 \
  --no-allow-unauthenticated

chmod u+x deploy.sh
./deploy.sh

gcloud run services add-iam-policy-binding sms-service --member=serviceAccount:pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com --role=roles/run.invoker --region us-central1 --platform managed
SMS_SERVICE_URL=$(gcloud run services describe sms-service --platform managed --region us-central1 --format="value(status.address.url)")
echo $SMS_SERVICE_URL
gcloud pubsub subscriptions create sms-service-sub --topic new-lab-report --push-endpoint=$SMS_SERVICE_URL --push-auth-service-account=pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
~/pet-theory/lab05/lab-service/post-reports.sh

cd ~/pet-theory/lab05/email-service || exit 1

#...
#
#function sendEmail() {
#  throw 'Email server is down';
#  console.log('Sending email');
#}
#...

./deploy.sh
~/pet-theory/lab05/lab-service/post-reports.sh

#function sendEmail() {
#  console.log('Sending email');
#}

./deploy.sh