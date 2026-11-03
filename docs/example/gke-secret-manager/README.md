# Google Secret Manager on GKE

This example deploys Bindplane to GKE with its sensitive configuration stored in
[Google Secret Manager](https://cloud.google.com/secret-manager) instead of a
hand-made Kubernetes Secret.

With `gsm.enabled: true` the chart renders two resources:

- A `SecretProviderClass` (provider `gke`) that lists the Secret Manager secrets to read.
- A `SecretSync` that tells GKE to copy those secrets into a Kubernetes Secret named
  `config.secret` (`bindplane` by default).

Bindplane reads the Kubernetes Secret the same way it does without this feature.
The Bindplane pods do not mount a CSI volume, so `extraVolumes` and
`extraVolumeMounts` are not needed.

See Google's [Sync Secret Manager secrets to Kubernetes Secrets](https://cloud.google.com/secret-manager/docs/sync-k8-secrets)
for details about the feature.

## Prerequisites

- GKE 1.33 or newer.
- [Workload Identity Federation for GKE](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
  enabled on the cluster. It is enabled by default on Autopilot clusters.
- Secret Sync enabled on the cluster (`--enable-secret-sync`). This installs both the
  `SecretSync` and `SecretProviderClass` CRDs. The Secret Manager CSI add-on
  (`--enable-secret-manager`) is not required.
- The Secret Manager API enabled in the project that stores the secrets.

The examples below use these variables:

```bash
CLUSTER_PROJECT_ID=my-project        # project that runs the GKE cluster
CLUSTER_PROJECT_NUMBER="$(gcloud projects describe "$CLUSTER_PROJECT_ID" --format='value(projectNumber)')"
SECRET_PROJECT_ID=my-project         # project that stores the secrets (gsm.projectId)
LOCATION=us-central1
CLUSTER=my-cluster
NAMESPACE=bindplane
RELEASE=bindplane
```

### Enable Secret Sync

New Standard cluster:

```bash
gcloud container clusters create "$CLUSTER" \
  --project "$CLUSTER_PROJECT_ID" \
  --location "$LOCATION" \
  --workload-pool="${CLUSTER_PROJECT_ID}.svc.id.goog" \
  --enable-secret-sync
```

Existing cluster. Run the two updates separately; `gcloud` does not accept both flags in one update:

```bash
gcloud container clusters update "$CLUSTER" --project "$CLUSTER_PROJECT_ID" --location "$LOCATION" \
  --workload-pool="${CLUSTER_PROJECT_ID}.svc.id.goog"
gcloud container clusters update "$CLUSTER" --project "$CLUSTER_PROJECT_ID" --location "$LOCATION" \
  --enable-secret-sync
```

Optionally enable rotation, so changes in Secret Manager are copied to the
Kubernetes Secret (the default interval is 2 minutes). See [Rotation](#rotation).

```bash
gcloud container clusters update "$CLUSTER" --project "$CLUSTER_PROJECT_ID" --location "$LOCATION" \
  --enable-secret-sync-rotation --secret-sync-rotation-interval=300s
```

## Create the Secrets

Create one Secret Manager secret per value. Use `printf '%s'` rather than `echo`:
values are copied byte for byte, and a trailing newline would end up in
Bindplane's configuration.

```bash
printf '%s' 'my-license-key'   | gcloud secrets create bindplane-license         --project "$SECRET_PROJECT_ID" --data-file=-
printf '%s' 'admin'            | gcloud secrets create bindplane-username        --project "$SECRET_PROJECT_ID" --data-file=-
printf '%s' 'my-password'      | gcloud secrets create bindplane-password        --project "$SECRET_PROJECT_ID" --data-file=-
printf '%s' "$(uuidgen)"       | gcloud secrets create bindplane-sessions-secret --project "$SECRET_PROJECT_ID" --data-file=-
# Optional, when Postgres credentials are read from the synced Secret:
printf '%s' 'postgres-user'     | gcloud secrets create bindplane-postgres-username --project "$SECRET_PROJECT_ID" --data-file=-
printf '%s' 'postgres-password' | gcloud secrets create bindplane-postgres-password --project "$SECRET_PROJECT_ID" --data-file=-
```

## Grant Access

GKE reads the secrets as the Kubernetes ServiceAccount named in the SecretSync.
By default this is the chart's ServiceAccount, whose name is the chart's full name:

| Values / release name | ServiceAccount |
|-----------------------|----------------|
| `fullnameOverride` set | the `fullnameOverride` value |
| release name contains `bindplane` (or `nameOverride`, when set), e.g. `bindplane` | the release name, e.g. `bindplane` |
| anything else, e.g. `prod` | `<release>-bindplane` (or `<release>-<nameOverride>`), e.g. `prod-bindplane` |

To confirm the name, render the ServiceAccount from this directory:

```bash
helm repo add bindplane https://observiq.github.io/bindplane-op-helm
helm repo update

helm template "$RELEASE" bindplane/bindplane -n "$NAMESPACE" -f values.yaml \
  -s templates/service-account.yml | grep '  name:'
```

Grant `roles/secretmanager.secretAccessor` to that ServiceAccount on **every**
secret in `gsm.spc.secrets`. If any one secret cannot be read, the whole sync fails.
The project number and workload pool are the **cluster's**, even when the secrets
live in another project.

```bash
KSA=bindplane
MEMBER="principal://iam.googleapis.com/projects/${CLUSTER_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${CLUSTER_PROJECT_ID}.svc.id.goog/subject/ns/${NAMESPACE}/sa/${KSA}"

for secret in bindplane-license bindplane-username bindplane-password bindplane-sessions-secret \
              bindplane-postgres-username bindplane-postgres-password; do
  gcloud secrets add-iam-policy-binding "$secret" \
    --project "$SECRET_PROJECT_ID" \
    --role roles/secretmanager.secretAccessor \
    --member "$MEMBER"
done
```

IAM changes can take a few minutes to apply. Until then the SecretSync may report
`ProviderError`.

No ServiceAccount annotation is needed. If you already set
`serviceAccount.annotations` with `iam.gke.io/gcp-service-account` (for example,
for Pub/Sub), see [ServiceAccount annotations](#serviceaccount-annotations).

To use a separate ServiceAccount for the sync, create it in the release
namespace, grant it access as above, and set `gsm.secretsync.serviceAccountName`.

## Configure

Edit the [values.yaml](./values.yaml) file in this directory.

- `gsm.projectId` is the project that stores the secrets.
- Each `gsm.spc.secrets[]` entry names a Secret Manager secret (`secretName`) and
  the file name it is returned as (`path`). `version` is optional (a version number or
  alias) and defaults to `latest`.
- Each `gsm.secretsync.secretObject.data[]` entry copies a `path` (`sourcePath`)
  into a key of the Kubernetes Secret (`targetKey`).
- The chart reads `license`, `username`, `password` and `sessions_secret` from
  `config.secret`. Set `config.licenseUseSecret: true` and leave `config.license`,
  `config.username`, `config.password` and `config.sessions_secret` unset, because
  values set there override the Secret.

The chart validates this configuration and fails to render if, for example,
`gsm.projectId` is empty, a `sourcePath` has no matching `path`, or a key the chart
reads is not synced.

## Install

Do not create the `bindplane` Kubernetes Secret yourself; GKE creates it.

```bash
helm upgrade --install "$RELEASE" bindplane/bindplane \
  --namespace "$NAMESPACE" --create-namespace \
  --values values.yaml
```

The install notes print the grant command with the release namespace and ServiceAccount
filled in. Replace `CLUSTER_PROJECT_NUMBER` and `CLUSTER_PROJECT_ID` with the cluster project's
values, or use the `MEMBER` value from [Grant Access](#grant-access).

## Verify

```bash
kubectl -n "$NAMESPACE" get secretproviderclass,secretsync
kubectl -n "$NAMESPACE" describe secretsync bindplane
kubectl -n "$NAMESPACE" get secret bindplane -o jsonpath='{.data}' | jq 'keys'
kubectl -n "$NAMESPACE" get pods
```

Until the Secret exists, Bindplane pods report `CreateContainerConfigError`. They
start on their own once the sync succeeds.

## Operations

### Rotation

With rotation enabled, GKE updates the Kubernetes Secret after a new secret version
is added (or `latest` changes). Bindplane reads these values as environment
variables at startup, so restart the workloads to apply them:

```bash
kubectl -n "$NAMESPACE" rollout restart deployment,statefulset -l app.kubernetes.io/instance="$RELEASE"
```

### Existing Kubernetes Secret

If you are migrating from a Secret you created by hand, delete it (or choose a new
`config.secret` name) before installing. The SecretSync controller does not take
over a Secret it did not create. Instead it reports
`UserInputValidationFailed: Secret create or update failed due to SecretProviderClass or SecretSync error`
and leaves the existing Secret unchanged. Once that Secret is deleted, the controller
creates its own.

```bash
kubectl -n "$NAMESPACE" delete secret bindplane
```

### Lifecycle

The synced Secret is owned by the SecretSync. Deleting the SecretSync deletes the
Secret. That includes `helm uninstall`, setting `gsm.enabled: false`, and renaming
`gsm.secretsync.name` or `config.secret`.

### ServiceAccount annotations

If the ServiceAccount used by the SecretSync has the
`iam.gke.io/gcp-service-account` annotation, GKE impersonates that Google service
account to read Secret Manager, and the principal binding above is not used. Either:

- set `gsm.secretsync.serviceAccountName` to a separate ServiceAccount without the
  annotation and grant that ServiceAccount access as described in [Grant Access](#grant-access), or
- grant the Google service account access and allow the Kubernetes ServiceAccount to impersonate it:

  ```bash
  GSA=my-gsa@my-project.iam.gserviceaccount.com
  gcloud iam service-accounts add-iam-policy-binding "$GSA" \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${CLUSTER_PROJECT_ID}.svc.id.goog[${NAMESPACE}/${KSA}]"
  for secret in bindplane-license bindplane-username bindplane-password bindplane-sessions-secret \
                bindplane-postgres-username bindplane-postgres-password; do
    gcloud secrets add-iam-policy-binding "$secret" --project "$SECRET_PROJECT_ID" \
      --role roles/secretmanager.secretAccessor --member "serviceAccount:${GSA}"
  done
  ```

## Troubleshooting

`kubectl describe secretsync` reporting `ProviderError`
(`Secret creation failed due to provider error, check the logs or the events for more information.`)
means GKE could not read at least one of the secrets from Secret Manager. The status
does not include the underlying error and no events are recorded. If the Secret was
synced before, it keeps its last synced values. Check, in order:

1. Every secret in `gsm.spc.secrets` has a `roles/secretmanager.secretAccessor`
   binding for the exact principal: the cluster's project number and workload pool,
   the release namespace and the ServiceAccount name from [Grant Access](#grant-access).
2. The ServiceAccount does not have an `iam.gke.io/gcp-service-account` annotation,
   or that Google service account has access (see [ServiceAccount annotations](#serviceaccount-annotations)).
3. `gsm.projectId`, each `secretName` and each `version` exist, and the version is enabled:
   `gcloud secrets versions describe latest --secret bindplane-license --project "$SECRET_PROJECT_ID"`.
4. The cluster has a workload pool:
   `gcloud container clusters describe "$CLUSTER" --project "$CLUSTER_PROJECT_ID" --location "$LOCATION" --format='value(workloadIdentityConfig.workloadPool)'`.
5. No VPC Service Controls perimeter blocks Secret Manager for the cluster.

`UserInputValidationFailed` usually means a Secret named `config.secret` already
exists and was not created by the SecretSync. See [Existing Kubernetes Secret](#existing-kubernetes-secret).

After fixing IAM, allow a few minutes for the change to apply. With rotation enabled,
GKE retries at every rotation interval.
