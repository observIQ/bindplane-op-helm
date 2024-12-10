#!/bin/bash

set -e

client_id=$1
client_secret=$2

if [ -z "$client_id" ] || [ -z "$client_secret" ]; then
  echo "Client ID and Client Secret are required"
  exit 1
fi

cat <<EOF > test/cases/oidc/values.yaml
config:
  sessions_secret: 4484766F-5016-4077-B8E0-0DE1D637854B
  server_url: http://localhost:3001
  licenseUseSecret: true

backend:
  type: postgres
  postgres:
    host: postgres.postgres.svc.cluster.local
    database: bindplane
    username: postgres
    password: password
    maxConnections: 20
    
eventbus:
  type: nats

replicas: 1

resources:
  requests:
    memory: 100Mi
    cpu: 100m
  limits:
    memory: 100Mi

nats:
  resources:
    requests:
      memory: 100Mi
      cpu: 100m
    limits:
      memory: 100Mi

auth:
  type: oidc
  oidc:
    issuer: "https://accounts.google.com"
    oauth2ClientID: "$client_id"
    oauth2ClientSecret: "$client_secret"
    scopes: [
      "openid",
      "profile",
      "email"
    ]

image:
  name: bmedora/bindplane-ee-amd64
  tag: oidc.1

EOF
