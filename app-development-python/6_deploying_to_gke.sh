#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/developingapps/v1.2/python/kubernetesengine ~/kubernetesengine
cd ~/kubernetesengine/start || exit 1
. prepare_environment.sh

gcloud beta container --project "qwiklabs-gcp-02-2419ab5bbb5c" clusters create "quiz-cluster" --zone "us-central1-b" --no-enable-basic-auth --cluster-version "1.14.10-gke.27" --machine-type "n1-standard-1" --image-type "COS" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/cloud-platform" --num-nodes "3" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/qwiklabs-gcp-02-2419ab5bbb5c/global/networks/default" --subnetwork "projects/qwiklabs-gcp-02-2419ab5bbb5c/regions/us-central1/subnetworks/default" --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0

# frontend Dockerfile
#FROM gcr.io/google_appengine/python
#
#RUN virtualenv -p python3.7 /env
#
#ENV VIRTUAL_ENV /env
#ENV PATH /env/bin:$PATH
#
#ADD requirements.txt /app/requirements.txt
#RUN pip install -r /app/requirements.txt
#
#ADD . /app
#
#CMD gunicorn -b 0.0.0.0:$PORT quiz:app

# backend Dockerfile
#FROM gcr.io/google_appengine/python
#
#RUN virtualenv -p python3.7 /env
#
#ENV VIRTUAL_ENV /env
#ENV PATH /env/bin:$PATH
#
#ADD requirements.txt /app/requirements.txt
#RUN pip install -r /app/requirements.txt
#
#ADD . /app
#
#CMD python -m quiz.console.worker

cd ~/kubernetesengine/start || exit 1
gcloud builds submit -t gcr.io/$DEVSHELL_PROJECT_ID/quiz-frontend ./frontend/
gcloud builds submit -t gcr.io/$DEVSHELL_PROJECT_ID/quiz-backend ./backend/

# update deployment and service .yaml

gcloud container clusters get-credentials quiz-cluster --zone us-central1-b --project qwiklabs-gcp-02-2419ab5bbb5c
kubectl create -f ./frontend-deployment.yaml
kubectl create -f ./backend-deployment.yaml
kubectl create -f ./frontend-service.yaml
