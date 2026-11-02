{{/*
Google Secret Manager (GSM) helpers. See docs/example/gke-secret-manager.
*/}}

{{/*
Name of the GSM SecretProviderClass.
*/}}
{{- define "bindplane.gsm.spcName" -}}
{{- default (printf "%s-gsm" (include "bindplane.fullname" .)) .Values.gsm.spc.name -}}
{{- end -}}

{{/*
Name of the SecretSync. GKE Secret Sync creates a Kubernetes Secret with the
same name, so this defaults to config.secret.
*/}}
{{- define "bindplane.gsm.syncName" -}}
{{- default .Values.config.secret .Values.gsm.secretsync.name -}}
{{- end -}}

{{/*
Kubernetes ServiceAccount the GKE Secret Sync controller authenticates as
(via Workload Identity Federation for GKE). Defaults to the chart's ServiceAccount.
*/}}
{{- define "bindplane.gsm.serviceAccountName" -}}
{{- default (include "bindplane.fullname" .) .Values.gsm.secretsync.serviceAccountName -}}
{{- end -}}

{{/*
Validate gsm.* values when gsm.enabled is true. Mistakes fail at render time
(helm template / lint / install) instead of surfacing as an opaque SecretSync
"provider error" or as pods stuck in CreateContainerConfigError.
*/}}
{{- define "bindplane.gsm.validate" -}}
{{- if (.Values.gsm).enabled -}}
{{- if not .Values.gsm.projectId -}}
{{- fail "gsm.projectId is required when gsm.enabled is true" -}}
{{- end -}}
{{- if not .Values.gsm.spc.secrets -}}
{{- fail "gsm.spc.secrets must contain at least one entry when gsm.enabled is true" -}}
{{- end -}}
{{- $paths := list -}}
{{- range .Values.gsm.spc.secrets -}}
{{- if has .path $paths -}}
{{- fail (printf "gsm.spc.secrets: duplicate path %q" .path) -}}
{{- end -}}
{{- $paths = append $paths .path -}}
{{- end -}}
{{- if .Values.gsm.secretsync.enabled -}}
{{- if not .Values.gsm.secretsync.secretObject.data -}}
{{- fail "gsm.secretsync.secretObject.data must contain at least one {sourcePath, targetKey} entry when gsm.secretsync.enabled is true" -}}
{{- end -}}
{{- $keys := list -}}
{{- range .Values.gsm.secretsync.secretObject.data -}}
{{- if not (has .sourcePath $paths) -}}
{{- fail (printf "gsm.secretsync.secretObject.data: sourcePath %q does not match any gsm.spc.secrets[].path (%s)" .sourcePath (join ", " $paths)) -}}
{{- end -}}
{{- if has .targetKey $keys -}}
{{- fail (printf "gsm.secretsync.secretObject.data: duplicate targetKey %q" .targetKey) -}}
{{- end -}}
{{- $keys = append $keys .targetKey -}}
{{- end -}}
{{- $syncName := include "bindplane.gsm.syncName" . -}}
{{- /* Wiring checks: only when the synced Secret is the one the chart reads. */ -}}
{{- if eq $syncName .Values.config.secret -}}
{{- if and (has "license" $keys) (not .Values.config.licenseUseSecret) (not .Values.config.license) -}}
{{- fail "gsm syncs a 'license' key into config.secret, but config.licenseUseSecret is false so it would be ignored. Set config.licenseUseSecret=true." -}}
{{- end -}}
{{- if and .Values.config.licenseUseSecret (not .Values.config.license) (not (has "license" $keys)) -}}
{{- fail "config.licenseUseSecret is true, but gsm.secretsync.secretObject.data has no 'license' targetKey" -}}
{{- end -}}
{{- if eq .Values.auth.type "system" -}}
{{- range $k := list "username" "password" -}}
{{- if and (not (index $.Values.config $k)) (not (has $k $keys)) -}}
{{- fail (printf "auth.type is 'system' and config.%s is empty, but gsm.secretsync.secretObject.data has no %q targetKey" $k $k) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- /* Postgres credentials read from the synced Secret must be synced too. */ -}}
{{- if and (eq .Values.backend.type "postgres") (eq .Values.backend.postgres.credentialSecret.name $syncName) -}}
{{- range $k := list .Values.backend.postgres.credentialSecret.usernameKey .Values.backend.postgres.credentialSecret.passwordKey -}}
{{- if not (has $k $keys) -}}
{{- fail (printf "backend.postgres.credentialSecret reads key %q from Secret %q, but gsm.secretsync.secretObject.data has no such targetKey" $k $syncName) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
