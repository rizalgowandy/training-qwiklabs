#!/usr/bin/env bash

gsutil -m cp -r gs://spls/gsp233/* .
cd tf-gke-k8s-service-lb || exit 1

# main.tf
#...
#
#variable "region" {
#  default = "us-west1"
#}
#
#variable "location" {
#  default = "us-west1-b"
#}
#
#variable "network_name" {
#  default = "tf-gke-k8s"
#}
#
#provider "google" {
#  region = var.region
#}
#
#resource "google_compute_network" "default" {
#  name                    = var.network_name
#  auto_create_subnetworks = false
#}
#
#resource "google_compute_subnetwork" "default" {
#  name                     = var.network_name
#  ip_cidr_range            = "10.127.0.0/20"
#  network                  = google_compute_network.default.self_link
#  region                   = var.region
#  private_ip_google_access = true
#}
#...

# k8s.tf
#provider "kubernetes" {
#  version = "~> 1.10.0"
#  host    = google_container_cluster.default.endpoint
#  token   = data.google_client_config.current.access_token
#  client_certificate = base64decode(
#    google_container_cluster.default.master_auth[0].client_certificate,
#  )
#  client_key = base64decode(google_container_cluster.default.master_auth[0].client_key)
#  cluster_ca_certificate = base64decode(
#    google_container_cluster.default.master_auth[0].cluster_ca_certificate,
#  )
#}
#
#resource "kubernetes_namespace" "staging" {
#  metadata {
#    name = "staging"
#  }
#}
#
#resource "google_compute_address" "default" {
#  name   = var.network_name
#  region = var.region
#}
#
#resource "kubernetes_service" "nginx" {
#  metadata {
#    namespace = kubernetes_namespace.staging.metadata[0].name
#    name      = "nginx"
#  }
#
#  spec {
#    selector = {
#      run = "nginx"
#    }
#
#    session_affinity = "ClientIP"
#
#    port {
#      protocol    = "TCP"
#      port        = 80
#      target_port = 80
#    }
#
#    type             = "LoadBalancer"
#    load_balancer_ip = google_compute_address.default.address
#  }
#}
#
#resource "kubernetes_replication_controller" "nginx" {
#  metadata {
#    name      = "nginx"
#    namespace = kubernetes_namespace.staging.metadata[0].name
#
#    labels = {
#      run = "nginx"
#    }
#  }
#
#  spec {
#    selector = {
#      run = "nginx"
#    }
#
#    template {
#      container {
#        image = "nginx:latest"
#        name  = "nginx"
#
#        resources {
#          limits {
#            cpu    = "0.5"
#            memory = "512Mi"
#          }
#
#          requests {
#            cpu    = "250m"
#            memory = "50Mi"
#          }
#        }
#      }
#    }
#  }
#}
#
#output "load-balancer-ip" {
#  value = google_compute_address.default.address
#}

terraform init
terraform apply --auto-approve
