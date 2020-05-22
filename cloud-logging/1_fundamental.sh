#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/getting-started-python
cd getting-started-python/bookshelf || exit 1
virtualenv -p python3 env
source env/bin/activate
pip3 install -r requirements.txt
gcloud app deploy