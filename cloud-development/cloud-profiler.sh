#!/usr/bin/env bash

go get -u github.com/GoogleCloudPlatform/golang-samples/profiler/...
cd ~/gopath/src/github.com/GoogleCloudPlatform/golang-samples/profiler/profiler_quickstart || exit 1
go run main.go