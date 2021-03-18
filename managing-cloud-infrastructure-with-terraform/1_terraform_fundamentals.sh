#!/usr/bin/env bash

touch instance.tf

#resource "google_compute_instance" "terraform" {
#  project      = "qwiklabs-gcp-00-0072bca1fbdc"
#  name         = "terraform"
#  machine_type = "n1-standard-1"
#  zone         = "us-central1-a"
#
#  boot_disk {
#    initialize_params {
#      image = "debian-cloud/debian-9"
#    }
#  }
#
#  network_interface {
#    network = "default"
#    access_config {
#    }
#  }
#}

terraform init
terraform apply --auto-approve
terraform show
