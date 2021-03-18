#!/usr/bin/env bash

wget https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
unzip terraform_0.14.7_linux_amd64.zip

sudo mv terraform /usr/local/bin/
cd ~/terraform-google-lb-http/examples/multi-backend-multi-mig-bucket-https-lb || exit 1

terraform init
terraform plan -out=tfplan -var 'project=qwiklabs-gcp-00-877d249af46c'
terraform apply tfplan
EXTERNAL_IP=$(terraform output | grep load-balancer-ip | cut -d = -f2 | xargs echo -n)
echo https://${EXTERNAL_IP}
