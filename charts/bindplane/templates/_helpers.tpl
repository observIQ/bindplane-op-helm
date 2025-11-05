{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "bindplane.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bindplane.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
The image to use
*/}}
{{- define "bindplane.image" -}}
{{- printf "%s" (default (printf "ghcr.io/observiq/bindplane-ee") .Values.image.name) }}
{{- end -}}

{{/*
The image tags to use
*/}}
{{- define "bindplane.tag" -}}
{{- printf "%s" (default (printf "%s" .Chart.AppVersion) .Values.image.tag) }}
{{- end -}}

{{/*
The Transform Agent image to use
*/}}
{{- define "bindplane.transform_agent" -}}
{{- printf "%s" (default (printf "ghcr.io/observiq/bindplane-transform-agent") .Values.transform_agent.name) }}
{{- end -}}

{{/*
The Transform Agent image tag to use
*/}}
{{- define "bindplane.transform_agent_tag" -}}
{{- printf "%s" (default (printf "%s-bindplane" .Chart.AppVersion) .Values.transform_agent.tag) }}
{{- end -}}

{{/*
Determine if bindplane should be managed by a StatefulSet or Deployment.

When bbolt is selected, always run as a StatefulSet. When Postgres or any other
remote storage option is selected, run as a Deployment.
*/}}
{{- define "bindplane.deployment_type" -}}
{{- if eq .Values.backend.type "bbolt" -}}
{{- printf "%s" "StatefulSet" -}}
{{- else -}}
{{- printf "%s" "Deployment" -}}
{{- end -}}
{{- end -}}

{{/*
Merge ldap and active-directory into one auth type because they
have identical configuration as of right now. This makes it easier to check for
instead of checking 'if ldap || active-directory'.
*/}}
{{- define "bindplane.auth.type" -}}
{{- if or (eq .Values.auth.type "ldap") (eq .Values.auth.type "active-directory") -}}
{{- printf "%s" "ldap" }}
{{- else }}
{{- printf "%s" .Values.auth.type }}
{{- end -}}
{{- end -}}

{{- define "bindplane.auth_oidc_scopes" -}}
{{- join "," .Values.auth.oidc.scopes }}
{{- end -}}
