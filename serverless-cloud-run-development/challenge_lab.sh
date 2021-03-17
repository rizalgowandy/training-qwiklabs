gcloud config set project "$(gcloud projects list --format='value(PROJECT_ID)'  --filter='qwiklabs-gcp')"

gcloud config set run/region us-central1
gcloud config set run/platform managed
git clone https://github.com/rosera/pet-theory.git && cd pet-theory/lab07 || exit 1

cd ~/pet-theory/lab07/unit-api-billing || exit 1
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.1

gcloud run deploy public-billing-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.1 \
  --allow-unauthenticated \
  --platform managed \
  --region us-central1 \

echo ">>>> DONE: Deploy a Public Billing Service"

cd ~/pet-theory/lab07/staging-frontend-billing || exit 1
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1

gcloud run deploy frontend-staging-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1 \
  --allow-unauthenticated \
  --platform managed \
  --region us-central1 \

echo ">>>> DONE: Deploy the Frontend Service"

cd ~/pet-theory/lab07/staging-api-billing || exit 1
gcloud beta run services delete public-billing-service

gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.2

gcloud run deploy private-billing-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.2 \
  --no-allow-unauthenticated \
  --platform managed \
  --region us-central1 \

echo ">>>> DONE: Deploy a Private Billing Service"

BILLING_SERVICE=private-billing-service
BILLING_URL=$(gcloud run services describe $BILLING_SERVICE --format "value(status.URL)")

curl -X get -H "Authorization: Bearer $(gcloud auth print-identity-token)" $BILLING_URL

gcloud iam service-accounts create billing-service-sa --display-name "Billing Service Cloud Run"

echo ">>>> DONE: Create a Billing Service Account"

cd ~/pet-theory/lab07/prod-api-billing || exit 1
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/billing-prod-api:0.1

gcloud run deploy billing-prod-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/billing-prod-api:0.1 \
  --no-allow-unauthenticated \
  --platform managed \
  --region us-central1 \

gcloud run services add-iam-policy-binding billing-prod-service \
  --member=serviceAccount:billing-service-sa@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
  --role=roles/run.invoker

PROD_BILLING_SERVICE=private-billing-service

PROD_BILLING_URL=$(gcloud run services \
  describe $PROD_BILLING_SERVICE \
  --format "value(status.URL)")

curl -X get -H "Authorization: Bearer \
  $(gcloud auth print-identity-token)" \
  $PROD_BILLING_URL

gcloud iam service-accounts create frontend-service-sa --display-name "Billing Service Cloud Run Invoker"

echo ">>>> DONE: Deploy a Billing Service in Production"

cd ~/pet-theory/lab07/prod-frontend-billing || exit 1
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-prod:0.1

gcloud run deploy frontend-prod-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-prod:0.1 \
  --allow-unauthenticated \
  --platform managed \
  --region us-central1 \

echo ">>>> DONE: Create a Frontend Service Account"

gcloud run services add-iam-policy-binding frontend-prod-service \
  --member=serviceAccount:frontend-service-sa@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
  --role=roles/run.invoker

echo ">>>> DONE: Deploy the Frontend Service in Production"
