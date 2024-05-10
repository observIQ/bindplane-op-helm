#!/usr/bin/env bash

set -e

curl -L -o step-cli_amd64.deb https://github.com/smallstep/cli/releases/download/v0.26.1/step-cli_0.26.1_amd64.deb
sudo apt-get install -y -qq -f ./step-cli_amd64.deb


step certificate create \
  ca.ldap.example.com \
    ca.crt ca.key \
    --profile root-ca \
    --no-password \
    --insecure \
    --not-after=87600h

step certificate create \
    'ldap.example.com' \
    client.crt client.key \
    --profile leaf \
    --not-after 2160h \
    --no-password \
    --insecure \
    --ca ca.crt \
    --ca-key ca.key

kubectl create secret generic ldap-tls \
    --from-file ca.crt \
    --from-file client.crt \
    --from-file client.key
