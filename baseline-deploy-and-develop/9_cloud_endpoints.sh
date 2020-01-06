#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/endpoints-quickstart
cd endpoints-quickstart || exit 1
cd scripts || exit 1
./deploy_api.sh
./deploy_app.sh
./query_api.sh JFK
./generate_traffic.sh

# with rate limit
./deploy_api.sh ../openapi_with_ratelimit.yaml
./deploy_app.sh
export API_KEY=YOUR-API-KEY
./query_api_with_key.sh $API_KEY