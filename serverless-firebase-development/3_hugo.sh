#!/usr/bin/env bash

_HUGO_VERSION=0.69.2

echo Downloading Hugo version $_HUGO_VERSION...

wget \
  --quiet \
  -O hugo.tar.gz \
  https://github.com/gohugoio/hugo/releases/download/v${_HUGO_VERSION}/hugo_extended_${_HUGO_VERSION}_Linux-64bit.tar.gz

echo Extracting Hugo files into /tmp...

mv hugo.tar.gz /tmp
tar -C /tmp -xzf /tmp/hugo.tar.gz

echo The Hugo binary is now at /tmp/hugo.

cd ~ || exit 1
gcloud source repos create my_hugo_site
gcloud source repos clone my_hugo_site

cd ~ || exit 1
/tmp/hugo new site my_hugo_site --force

cd ~/my_hugo_site || exit 1
git submodule add \
  https://github.com/budparr/gohugo-theme-ananke.git \
  themes/ananke
echo 'theme = "ananke"' >> config.toml

cd ~/my_hugo_site || exit 1
/tmp/hugo server -D --bind 0.0.0.0 --port 8080

curl -sL https://firebase.tools | bash

cd ~/my_hugo_site || exit 1
firebase init

/tmp/hugo && firebase deploy

git config --global user.name "john.doe"
git config --global user.email "john.doe@gmail.com"

cd ~/my_hugo_site || exit 1
echo "resources" >> .gitignore

git add .
git commit -m "Add app to Cloud Source Repositories"
git push -u origin master

#student-03-cda8074cf32d@hugo-qldm-25865605-906aa43d00af9dd5:~/my_hugo_site$ cat cloudbuild.yaml
#steps:
#- name: 'gcr.io/cloud-builders/wget'
#  args:
#  - '--quiet'
#  - '-O'
#  - 'firebase'
#  - 'https://firebase.tools/bin/linux/latest'
#- name: 'gcr.io/cloud-builders/wget'
#  args:
#  - '--quiet'
#  - '-O'
#  - 'hugo.tar.gz'
#  - 'https://github.com/gohugoio/hugo/releases/download/v${_HUGO_VERSION}/hugo_extended_${_HUGO_VERSION}_Linux-64bit.tar.gz'
#  waitFor: ['-']
#- name: 'ubuntu:18.04'
#  args:
#  - 'bash'
#  - '-c'
#  - |
#    mv hugo.tar.gz /tmp
#    tar -C /tmp -xzf /tmp/hugo.tar.gz
#    mv firebase /tmp
#    chmod 755 /tmp/firebase
#    /tmp/hugo
#    /tmp/firebase deploy --project ${PROJECT_ID} --non-interactive --only hosting -m "Build ${BUILD_ID}"
#substitutions:
#  _HUGO_VERSION: 0.69.2

# setup code build trigger

git add .
git commit -m "I updated the site title"
git push -u origin master
