#!/usr/bin/env bash

gcloud beta compute --project=qwiklabs-gcp-01-01f47ba51ab1 instances create my-opencensus-demo --zone=us-central1-a --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=34613277326-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_only --tags=http-server,https-server --image=debian-10-buster-v20210316 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-balanced --boot-disk-device-name=my-opencensus-demo --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

gcloud compute --project=qwiklabs-gcp-01-01f47ba51ab1 firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

gcloud compute --project=qwiklabs-gcp-01-01f47ba51ab1 firewall-rules create default-allow-https --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:443 --source-ranges=0.0.0.0/0 --target-tags=https-server


gcloud compute ssh my-opencensus-demo \
  --zone=us-central1-a

sudo curl -O https://storage.googleapis.com/golang/go1.10.2.linux-amd64.tar.gz
sudo tar -xvf go1.10.2.linux-amd64.tar.gz
sudo mv go /usr/local
sudo apt-get update
sudo apt-get install git -y
export PATH=$PATH:/usr/local/go/bin
go get go.opencensus.io
go get contrib.go.opencensus.io/exporter/stackdriver

curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh
sudo apt-get update
sudo apt-get install stackdriver-agent -y
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh
sudo apt-get update
sudo apt-get install google-fluentd -y
exit

# main.go
#package main
#
#import (
#"context"
#"fmt"
#"log"
#"math/rand"
#"os"        // [[Add]]
#"time"
#
#"contrib.go.opencensus.io/exporter/stackdriver"   // [[Add]]
#"go.opencensus.io/stats"
#"go.opencensus.io/stats/view"
#
#monitoredrespb "google.golang.org/genproto/googleapis/api/monitoredres" // [[Add]]
#)
#
#var videoServiceInputQueueSize = stats.Int64(
#"my.videoservice.org/measure/input_queue_size",
#"Number of videos queued up in the input queue",
#stats.UnitDimensionless)
#
#func main() {
#// [[Add block]]
#// Setup metrics exporting to Stackdriver.
#exporter, err := stackdriver.NewExporter(stackdriver.Options{
#ProjectID: os.Getenv("MY_PROJECT_ID"),
#Resource: &monitoredrespb.MonitoredResource {
#Type: "gce_instance",
#Labels: map[string]string {
#"instance_id": os.Getenv("MY_GCE_INSTANCE_ID"),
#"zone": os.Getenv("MY_GCE_INSTANCE_ZONE"),
#},
#},
#})
#if err != nil {
#log.Fatalf("Cannot setup Stackdriver exporter: %v", err)
#}
#view.RegisterExporter(exporter)
#// [[End: add block]]
#
#ctx := context.Background()
#
#// Setup a view so that we can export our metric.
#if err := view.Register(&view.View{
#Name: "my.videoservice.org/measure/input_queue_size",
#Description: "Number of videos queued up in the input queue",
#Measure: videoServiceInputQueueSize,
#Aggregation: view.LastValue(),
#}); err != nil {
#log.Fatalf("Cannot setup view: %v", err)
#}
#// Set the reporting period to be once per second.
#view.SetReportingPeriod(1 * time.Second)
#
#// Here’s our fake video processing application. Every second, it
#// checks the length of the input queue (e.g., number of videos
#// waiting to be processed) and records that information.
#for {
#time.Sleep(1 * time.Second)
#queueSize := getQueueSize()
#
#// Record the queue size.
#stats.Record(ctx, videoServiceInputQueueSize.M(queueSize))
#fmt.Println("Queue size: ", queueSize)
#}
#}
#
#func getQueueSize() (int64) {
#// Fake out a queue size here by returning a random number between
#// 1 and 100.
#return rand.Int63n(100) + 1
#}

export MY_PROJECT_ID=qwiklabs-gcp-01-01f47ba51ab1
export MY_GCE_INSTANCE_ID=my-opencensus-demo
export MY_GCE_INSTANCE_ZONE=us-central1-a