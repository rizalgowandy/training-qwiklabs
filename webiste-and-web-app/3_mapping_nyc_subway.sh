#!/usr/bin/env bash

mkdir nyc-subway
cd nyc-subway || exit 1

goapp serve

mkdir data && cd data || exit 1

curl "https://data.cityofnewyork.us/api/geospatial/arq3-7z49?method=export&format=GeoJSON" -o subway-stations.geojson
curl "https://data.cityofnewyork.us/api/geospatial/3qz8-muuu?method=export&format=GeoJSON" -o subway-lines.geojson

cd ..

go get github.com/paulmach/go.geojson
go get github.com/dhconnelly/rtreego

go fmt *.go && goapp serve

go get github.com/smira/go-point-clustering

cd || exit 1
mv nyc-subway/ gopath/src/
cd gopath/src/nyc-subway/ || exit 1
gcloud app deploy