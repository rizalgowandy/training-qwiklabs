#!/usr/bin/env bash

# Open Cloud shell, run:
gcloud config set compute/zone us-east1-b
git clone https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/sample-app
gcloud container clusters get-credentials jenkins-cd
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install cd stable/jenkins
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &
printf "$(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)";echo
# Note: copy the output (Jenkins password)
#- Preview on Port 8000, Sign in jenkins
#    - username: admin
#    - password: see at your cloud shell output

# Back to Cloud shell, run:
cd sample-app || exit 1
kubectl create ns production
kubectl apply -f k8s/production -n production
kubectl apply -f k8s/canary -n production
kubectl apply -f k8s/services -n production

kubectl get svc
kubectl get service gceme-frontend -n production
git init
git config credential.helper gcloud.sh
git remote add origin https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/sample-app
git config --global user.email "student-00-b41cda9e7603@qwiklabs.net"
git config --global user.name "[YOUR_USERNAME]"
git add .
git commit -m "initial commit"
git push origin master

# Back to Jenkins Dashboard > Manage Jenkins (left pane) > manage Credentials
#     - Look at "Stores scoped", click Jenkins
#     - Click Global credentials (unrestricted)
#     - Click Add Credentials
#         - Kind: Google Service Account from metadata
#         - Project Name: <your_project_id>
#         - Click OK
#
# Back to Jenkins Dashboard > New Item (left pane)
#    Enter an item name: sample-app
#    Click Multibranch Pipeline
#    OK
#    *in sample-app config*
#        - Branch Sources: Git
#            - Project Repository: https://source.developers.google.com/p/[PROJECT_ID]/r/sample-app
#            - Credentials: qwiklabs service account
#        - Scan Multibranch Pipeline Triggers, check "Periodically if not otherwise run"
#            - Interval: 1 minute
#        - SAVE # building will take long time
#        # Note: Repeat if you see error msg while scanning Multibranch Pipeline Log
#        - CHECK YOUR FIRST CHECKPOINT
#

# Back to Cloud Shell
git checkout -b dev
sed -i "s/1.0.0/2.0.0/g" main.go
sed -i "s/blue/orange/g" html.go

# Back to Cloud Shell
git add Jenkinsfile html.go main.go
git commit -m "Version 2.0.0"
git push origin dev
curl http://localhost:8001/api/v1/namespaces/dev/services/gceme-frontend:80/proxy/version

# Back to Cloud Shell
curl http://localhost:8001/api/v1/namespaces/production/services/gceme-frontend:80/proxy/version
kubectl get service gceme-frontend -n production
git checkout -b canary
git push origin canary
git checkout master
git push origin master

# Back to Cloud Shell
export FRONTEND_SERVICE_IP=$(kubectl get -o \
jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)
while true; do curl http://$FRONTEND_SERVICE_IP/version; sleep 1; done
# after the you see output 2.0.0, run:
kubectl get service gceme-frontend -n production

# Note if task 4 not yet marked, try run:
git merge canary
git push origin master
