#!/usr/bin/env bash

gcloud config set project "$(gcloud projects list --format='value(PROJECT_ID)' --filter='qwiklabs-gcp')"

gcloud compute networks create griffin-dev-vpc \
  --subnet-mode=custom \
  --mtu=1460 \
  --bgp-routing-mode=regional
gcloud compute networks subnets create griffin-dev-wp \
  --range=192.168.16.0/20 \
  --network=griffin-dev-vpc \
  --region=us-east1
gcloud compute networks subnets create griffin-dev-mgmt \
  --range=192.168.32.0/20 \
  --network=griffin-dev-vpc \
  --region=us-east1

gsutil cp -r gs://cloud-training/gsp321/dm ~/
sed -i "s/SET_REGION/us-east1/g" dm/prod-network.yaml
gcloud deployment-manager deployments create griffin-prod --config dm/prod-network.yaml

gcloud compute instances create bastion \
  --zone=us-east1-b \
  --machine-type=n1-standard-1 \
  --tags=bastion \
  --network-interface subnet=griffin-dev-mgmt \
  --network-interface subnet=griffin-prod-mgmt

gcloud compute firewall-rules create allow-bastion-dev-ssh \
  --direction=INGRESS \
  --priority=1000 \
  --network=griffin-dev-vpc \
  --target-tags=bastion \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=192.168.32.0/20

gcloud compute firewall-rules create allow-bastion-prod-ssh \
  --direction=INGRESS \
  --priority=1000 \
  --network=griffin-prod-vpc \
  --target-tags=bastion \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=192.168.48.0/20

gcloud sql instances create griffin-dev-db \
  --database-version=MYSQL_5_6 \
  --root-password=asdf \
  --zone=us-east1-b

gcloud sql connect griffin-dev-db --user=root --quiet
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO "wp_user"@"%" IDENTIFIED BY "stormwind_rules";
FLUSH PRIVILEGES;
exit

gcloud container clusters create griffin-dev \
  --zone=us-east1-b \
  --network=griffin-dev-vpc \
  --subnetwork=griffin-dev-wp \
  --num-nodes=2 \
  --machine-type=n1-standard-4

gsutil cp -r gs://cloud-training/gsp321/wp-k8s ~/
sed -i "s/username_goes_here/wp_user/g" wp-k8s/wp-env.yaml
sed -i "s/password_goes_here/stormwind_rules/g" wp-k8s/wp-env.yaml

gcloud container clusters get-credentials griffin-dev --zone=us-east1-b
kubectl apply -f wp-k8s/wp-env.yaml
gcloud iam service-accounts keys create key.json --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
kubectl create secret generic cloudsql-instance-credentials --from-file key.json

sed -i "s/YOUR_SQL_INSTANCE/${DEVSHELL_PROJECT_ID}:us-east1:griffin-dev-db/g" wp-k8s/wp-deployment.yaml
kubectl create -f wp-k8s/wp-deployment.yaml
kubectl create -f wp-k8s/wp-service.yaml

USERNAME_2=student-01-de6c1830def1@qwiklabs.net
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member="user:${USERNAME_2}" --role="roles/editor"