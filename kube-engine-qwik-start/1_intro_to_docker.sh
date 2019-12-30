#!/usr/bin/env bash

gcloud auth list # get current active user
gcloud config list project # get current project id

docker run hello-world
docker images
docker ps -a

# running app
docker build -t node-app:0.1 .
docker run -p 4000:80 --name my-app node-app:0.1 # run foreground
docker stop my-app && docker rm my-app
docker run -p 4000:80 --name my-app -d node-app:0.1 # run background

# replace with container id
docker logs container_id
docker logs -f container_id
docker exec -it container_id bash # enter bash
docker inspect container_id
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_id

# stop and remove running app
docker stop "$(docker ps -q)"
docker rm "$(docker ps -aq)"

# remove images
docker rmi node-app:0.2 gcr.io/[project-id]/node-app node-app:0.1
docker rmi node:6
docker rmi "$(docker images -aq)" # remove remaining images
docker images

# publish
gcloud config list project # get the project id
docker tag node-app:0.2 gcr.io/[project-id]/node-app:0.2
docker images
docker push gcr.io/[project-id]/node-app:0.2

# pull
docker pull gcr.io/[project-id]/node-app:0.2
docker run -p 4000:80 -d gcr.io/[project-id]/node-app:0.2
