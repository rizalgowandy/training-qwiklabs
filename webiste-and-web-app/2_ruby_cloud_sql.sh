#!/usr/bin/env bash

gcloud sql instances create postgres-instance \
    --database-version POSTGRES_9_6 \
    --tier db-g1-small

gcloud sql users set-password postgres --host=% \
    --instance postgres-instance \
    --password secret

wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
mv cloud_sql_proxy.linux.amd64 cloud_sql_proxy
chmod +x cloud_sql_proxy
sudo mkdir /cloudsql
sudo chmod 0777 /cloudsql

gcloud sql instances describe postgres-instance | grep connectionName

./cloud_sql_proxy -dir=/cloudsql \
                  -instances="qwiklabs-gcp-03-2258a830513e:us-central1:postgres-instance"

gem install rails
rails --version

rails new app_name
cd app_name || exit 1

bundle exec rails server --port 8080
bundle add pg
bundle install

# database.yaml
#production:
#  adapter: postgresql
#  pool: 5
#  timeout: 5000
#  username: postgres
#  password: secret
#  database: postgres-database
#  host: /cloudsql/qwiklabs-gcp-03-2258a830513e:us-central1:postgres-instance

bundle exec rails generate model Cat name:string age:decimal
RAILS_ENV=production bundle exec rails db:create
RAILS_ENV=production bundle exec rails db:migrate

RAILS_ENV=production bundle exec rails console

bundle exec rails generate controller CatFriends index
bundle exec rails secret
export SECRET_KEY_BASE=[SECRET_KEY]
RAILS_ENV=production bundle exec rails assets:precompile

cd app_name || exit 1
gcloud app create
gcloud app deploy
