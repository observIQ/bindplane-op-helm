#!/usr/bin/env bash
# Render-only checks for the optional Google Secret Manager (GSM) integration.
# Run from the repository root. Requires helm and mikefarah/yq v4.
set -euo pipefail

CHART=charts/bindplane
NS=bindplane
RELEASE=release-name
BASE=test/cases/default/values.yaml
GSM=test/cases/gsm/values.yaml

yq --version 2>&1 | grep -q mikefarah || { echo "mikefarah/yq v4 is required" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

failures=0
pass() { echo "ok:   $*"; }
fail() { echo "FAIL: $*" >&2; failures=$((failures + 1)); }
assert_eq() { if [[ "$2" == "$3" ]]; then pass "$1"; else fail "$1: expected '$2', got '$3'"; fi; }
render() { local out="$1"; shift; helm template "$RELEASE" "$CHART" --namespace "$NS" "$@" > "$out"; }
count_kind() { yq ea "[select(.kind == \"$2\")] | length" "$1"; }
# expect_fail <description> <expected error substring> <helm args...>
expect_fail() {
  local desc="$1" want="$2" out
  shift 2
  if out="$(helm template "$RELEASE" "$CHART" --namespace "$NS" "$@" 2>&1)"; then
    fail "$desc: expected render to fail"
  elif grep -qF -- "$want" <<<"$out"; then
    pass "$desc"
  else
    fail "$desc: unexpected error: $out"
  fi
}

echo "== 1. Disabled by default"
render "$TMP/off.yaml" --values "$BASE"
assert_eq "no SecretProviderClass" 0 "$(count_kind "$TMP/off.yaml" SecretProviderClass)"
assert_eq "no SecretSync" 0 "$(count_kind "$TMP/off.yaml" SecretSync)"

echo "== 2. Enabled"
R="$TMP/on.yaml"
render "$R" --values "$GSM"
spc() { yq ea "select(.kind == \"SecretProviderClass\") | $1" "$R"; }
ss() { yq ea "select(.kind == \"SecretSync\") | $1" "$R"; }
assert_eq "one SecretProviderClass" 1 "$(count_kind "$R" SecretProviderClass)"
assert_eq "one SecretSync" 1 "$(count_kind "$R" SecretSync)"
assert_eq "SecretProviderClass apiVersion" "secrets-store.csi.x-k8s.io/v1" "$(spc .apiVersion)"
assert_eq "SecretProviderClass provider" "gke" "$(spc .spec.provider)"
assert_eq "SecretProviderClass namespace" "$NS" "$(spc .metadata.namespace)"
assert_eq "SecretSync apiVersion" "secret-sync.gke.io/v1" "$(ss .apiVersion)"
assert_eq "SecretSync namespace" "$NS" "$(ss .metadata.namespace)"
assert_eq "SecretSync name == config.secret" "$(yq '.config.secret' "$GSM")" "$(ss .metadata.name)"
assert_eq "SecretSync references the SecretProviderClass" "$(spc .metadata.name)" "$(ss .spec.secretProviderClassName)"
sa="$(yq ea 'select(.kind == "ServiceAccount") | .metadata.name' "$R")"
assert_eq "SecretSync ServiceAccount == chart ServiceAccount" "$sa" "$(ss .spec.serviceAccountName)"

spc '.spec.parameters.secrets | from_yaml | .[].resourceName' | sort > "$TMP/rn"
yq '.gsm.projectId as $p | .gsm.spc.secrets[] | "projects/" + $p + "/secrets/" + .secretName + "/versions/" + (.version // "latest")' "$GSM" | sort > "$TMP/rn.want"
if diff -q "$TMP/rn.want" "$TMP/rn" > /dev/null; then pass "SecretProviderClass resourceNames"; else fail "SecretProviderClass resourceNames: $(diff "$TMP/rn.want" "$TMP/rn" | tr '\n' ' ')"; fi

spc '.spec.parameters.secrets | from_yaml | .[].path' | sort > "$TMP/paths"
ss '.spec.secretObject.data[].sourcePath' | sort > "$TMP/sources"
if [[ -z "$(comm -13 "$TMP/paths" "$TMP/sources")" ]]; then pass "every sourcePath matches a SecretProviderClass path"; else fail "unmatched sourcePath: $(comm -13 "$TMP/paths" "$TMP/sources" | tr '\n' ' ')"; fi

name="$(ss .metadata.name)"
yq ea "[select(.kind == \"Deployment\" or .kind == \"StatefulSet\") | .spec.template.spec.containers[].env[]?
  | select(.valueFrom.secretKeyRef.name == \"$name\") | .valueFrom.secretKeyRef.key] | unique | .[]" "$R" | sort -u > "$TMP/consumed"
ss '.spec.secretObject.data[].targetKey' | sort -u > "$TMP/produced"
missing="$(comm -23 "$TMP/consumed" "$TMP/produced" | tr '\n' ' ')"
if [[ -z "${missing// /}" ]]; then pass "every key the workloads read from Secret '$name' is synced"; else fail "keys read from Secret '$name' but not synced: $missing"; fi

echo "== 3. Pinned versions and overrides"
cat > "$TMP/overrides.yaml" <<'EOF'
gsm:
  spc:
    name: custom-spc
  secretsync:
    serviceAccountName: gsm-sync
EOF
R2="$TMP/overrides-render.yaml"
render "$R2" --values "$GSM" --values "$TMP/overrides.yaml" --set-json 'gsm.spc.secrets[0].version=3'
assert_eq "numeric version renders" "projects/example-project/secrets/bindplane-license/versions/3" \
  "$(yq ea 'select(.kind == "SecretProviderClass") | .spec.parameters.secrets | from_yaml | .[0].resourceName' "$R2")"
R3="$TMP/large-version.yaml"
render "$R3" --values "$GSM" --set-json 'gsm.spc.secrets[0].version=1000000' --set-string 'gsm.spc.secrets[1].version=prod'
assert_eq "large numeric version renders as an integer" "projects/example-project/secrets/bindplane-license/versions/1000000" \
  "$(yq ea 'select(.kind == "SecretProviderClass") | .spec.parameters.secrets | from_yaml | .[0].resourceName' "$R3")"
assert_eq "version alias renders" "projects/example-project/secrets/bindplane-username/versions/prod" \
  "$(yq ea 'select(.kind == "SecretProviderClass") | .spec.parameters.secrets | from_yaml | .[1].resourceName' "$R3")"
assert_eq "custom SecretProviderClass name" "custom-spc" "$(yq ea 'select(.kind == "SecretSync") | .spec.secretProviderClassName' "$R2")"
assert_eq "custom SecretSync ServiceAccount" "gsm-sync" "$(yq ea 'select(.kind == "SecretSync") | .spec.serviceAccountName' "$R2")"

echo "== 4. SecretSync disabled renders only the SecretProviderClass"
render "$TMP/spc-only.yaml" --values "$GSM" --set gsm.secretsync.enabled=false
assert_eq "one SecretProviderClass" 1 "$(count_kind "$TMP/spc-only.yaml" SecretProviderClass)"
assert_eq "no SecretSync" 0 "$(count_kind "$TMP/spc-only.yaml" SecretSync)"

echo "== 5. Invalid configuration is rejected"
expect_fail "empty projectId" "gsm.projectId is required" --values "$GSM" --set gsm.projectId=
expect_fail "no secrets" "gsm.spc.secrets must contain at least one entry" --values "$BASE" \
  --set gsm.enabled=true --set gsm.projectId=p
expect_fail "no data" "gsm.secretsync.secretObject.data must contain at least one" --values "$GSM" \
  --set-json 'gsm.secretsync.secretObject.data=[]'
expect_fail "sourcePath without a matching path" "does not match any gsm.spc.secrets[].path" --values "$GSM" \
  --set 'gsm.secretsync.secretObject.data[0].sourcePath=nope.txt' --set 'gsm.secretsync.secretObject.data[0].targetKey=license'
expect_fail "license synced without licenseUseSecret" "config.licenseUseSecret" --values "$GSM" --set config.licenseUseSecret=false
expect_fail "postgres credential key not synced" "backend.postgres.credentialSecret" --values "$GSM" \
  --set backend.postgres.credentialSecret.passwordKey=missing
expect_fail "issue-style fileName key is rejected" "fileName" --values "$GSM" \
  --set 'gsm.spc.secrets[0].secretName=s' --set 'gsm.spc.secrets[0].fileName=s.txt'
expect_fail "targetKey that the SecretSync CRD rejects" "match pattern" --values "$GSM" \
  --set 'gsm.secretsync.secretObject.data[6].sourcePath=license.txt' --set 'gsm.secretsync.secretObject.data[6].targetKey=-bad'
expect_fail "invalid ServiceAccount name" "match pattern" --values "$GSM" --set gsm.secretsync.serviceAccountName=Bad_SA

if (( failures > 0 )); then
  echo "$failures GSM template check(s) failed" >&2
  exit 1
fi
echo "All GSM template checks passed"
