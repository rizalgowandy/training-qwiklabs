#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/developingapps/v1.2/python/firebase ~/firebase
cd ~/firebase/start || exit 1
. prepare_environment.sh
python run_server.py

# create a firebase https://console.firebase.google.com/?pli=1
# copy the sdk script to index.html

# add to index.html
# <script src="https://www.gstatic.com/firebasejs/7.5.2/firebase-auth.js"></script>
