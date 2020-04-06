#!/usr/bin/env bash

# Create provider.tf

# Create folder and configuration files
cd tfinfra || exit 1
terraform init

# Format files
terraform fmt

# Initialize again
terraform init

# Execute plan
terraform plan

# Apply plan
terraform apply