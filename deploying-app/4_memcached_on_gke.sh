#!/usr/bin/env bash

gcloud container clusters create demo-cluster --num-nodes 3 --zone us-central1-f
cd ~
wget https://kubernetes-helm.storage.googleapis.com/helm-v2.14.0-linux-amd64.tar.gz || exit 1

mkdir helm-v2.14.0
tar zxfv helm-v2.14.0-linux-amd64.tar.gz -C helm-v2.14.0
export PATH="$(echo ~)/helm-v2.14.0/linux-amd64:$PATH"

kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
helm repo update

helm install stable/memcached --name mycache --set replicaCount=3
kubectl get pods
kubectl get service mycache-memcached -o jsonpath="{.spec.clusterIP}" ; echo

# In this lab the service creates a DNS record for a hostname of the form:
#[SERVICE_NAME].[NAMESPACE].svc.cluster.local

kubectl get endpoints mycache-memcached
kubectl run -it --rm alpine --image=alpine:3.6 --restart=Never nslookup mycache-memcached.default.svc.cluster.local

kubectl run -it --rm python --image=python:3.6-alpine --restart=Never python
#import socket
#print(socket.gethostbyname_ex('mycache-memcached.default.svc.cluster.local'))
#exit()

kubectl run -it --rm alpine --image=alpine:3.6 --restart=Never telnet mycache-memcached-0.mycache-memcached.default.svc.cluster.local 11211
set mykey 0 0 5
hello
get mykey

kubectl run -it --rm python --image=python:3.6-alpine --restart=Never sh
pip install pymemcache
python
#import socket
#from pymemcache.client.hash import HashClient
#_, _, ips = socket.gethostbyname_ex('mycache-memcached.default.svc.cluster.local')
#servers = [(ip, 11211) for ip in ips]
#client = HashClient(servers, use_pooling=True)
#client.set('mykey', 'hello')
#client.get('mykey')
#exit()

helm delete mycache --purge
helm install stable/mcrouter --name=mycache --set memcached.replicaCount=3
kubectl get pods
MCROUTER_POD_IP=$(kubectl get pods -l app=mycache-mcrouter -o jsonpath="{.items[0].status.podIP}")
kubectl run -it --rm alpine --image=alpine:3.6 --restart=Never telnet $MCROUTER_POD_IP 5000
set anotherkey 0 0 15
Mcrouter is fun
get anotherkey

cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: sample-application-py
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: sample-application-py
    spec:
      containers:
        - name: python
          image: python:3.6-alpine
          command: [ "sh", "-c"]
          args:
          - while true; do sleep 10; done;
          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
EOF
kubectl get pods
POD=$(kubectl get pods -l app=sample-application-py -o jsonpath="{.items[0].metadata.name}")
kubectl exec -it $POD -- sh -c 'echo $NODE_NAME'
#gke-demo-cluster-default-pool-XXXXXXXX-XXXX

kubectl run -it --rm alpine --image=alpine:3.6 --restart=Never telnet gke-demo-cluster-default-pool-XXXXXXXX-XXXX 5000
get anotherkey

kubectl exec -it $POD -- sh
pip install pymemcache
python
#import os
#from pymemcache.client.base import Client
#
#NODE_NAME = os.environ['NODE_NAME']
#client = Client((NODE_NAME, 5000))
#client.set('some_key', 'some_value')
#result = client.get('some_key')
#result
#result = client.get('anotherkey')
#result