#!/usr/bin/env bash

gcloud iam service-accounts create quickstart
gcloud iam service-accounts keys create key.json --iam-account quickstart@ <your-project-123 >.iam.gserviceaccount.com
gcloud auth activate-service-account --key-file key.json
gcloud auth print-access-token

# request.json
# {
#   "inputUri":"gs://spls/gsp154/video/chicago.mp4",
#   "features": [
#   "LABEL_DETECTION"
#   ]
# }

curl -s -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer ACCESS_TOKEN' \
    'https://videointelligence.googleapis.com/v1/videos:annotate' \
    -d @request.json
# get operation name
# {
#   "name": "projects/661456385913/locations/asia-east1/operations/14430783407447602829"
# }

curl -s -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer ACCESS_TOKEN' \
    'https://videointelligence.googleapis.com/v1/operations/OPERATION_NAME'