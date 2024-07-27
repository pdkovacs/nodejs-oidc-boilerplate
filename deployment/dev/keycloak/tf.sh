#!/bin/bash

tf_command=$1

#APP_HOSTNAME=$(ipconfig getifaddr en1)
APP_HOSTNAME=node-boilerplate.internal

. ~/.keycloak.secrets

[ -f ~/.node-boilerplate.secrets ] || echo "NODE_BOILERPLATE_CLIENT_SECRET=$(openssl rand -base64 32)" > ~/.node-boilerplate.secrets
. ~/.node-boilerplate.secrets

# export TF_LOG=DEBUG
echo ">>>>>>>> KEYCLOAK_URL: $KEYCLOAK_URL"
terraform init &&
  terraform $tf_command -auto-approve \
    -var=keycloak_url=$KEYCLOAK_URL \
    -var="tf_client_secret=$KEYCLOAK_TF_CLIENT_SECRET" \
    -var="client_secret=$NODE_BOILERPLATE_CLIENT_SECRET" \
    -var="app_hostname=$APP_HOSTNAME"
