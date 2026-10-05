#!/bin/bash

set -euo pipefail

# This check ensures the optional GSM templates render when enabled AND when the
# relevant CRDs are present. We simulate CRD presence using --api-versions.

rendered="$(
  helm template release-name charts/bindplane \
    --set gsm.enabled=true \
    --set gsm.projectId=example-project \
    --set gsm.spc.secrets[0].secretName=bindplane-license \
    --set gsm.spc.secrets[0].path=license.txt \
    --set gsm.secretsync.secretObject.data[0].sourcePath=license.txt \
    --set gsm.secretsync.secretObject.data[0].targetKey=license \
    --api-versions secrets-store.csi.x-k8s.io/v1/SecretProviderClass \
    --api-versions secret-sync.gke.io/v1/SecretSync
)"

echo "$rendered" | grep -q "kind: SecretProviderClass"
echo "$rendered" | grep -q "kind: SecretSync"

