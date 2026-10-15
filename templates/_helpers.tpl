{{/*
Expand the name of the chart.
*/}}
{{- define "feedbox.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "feedbox.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "feedbox.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "feedbox.labels" -}}
helm.sh/chart: {{ include "feedbox.chart" . }}
{{ include "feedbox.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "feedbox.selectorLabels" -}}
app.kubernetes.io/name: {{ include "feedbox.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "feedbox.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "feedbox.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validate that only one routing resource is enabled.
*/}}
{{- define "feedbox.validateRouting" -}}
{{- if and .Values.ingress.enabled .Values.httpRoute.enabled -}}
{{- fail "Only one of ingress.enabled or httpRoute.enabled may be true; set exactly one to false." -}}
{{- end }}
{{- end }}

{{/*
Validate SSO JWT settings when SSO is enabled. Issuer and audience must be
set — mp.jwt.verify.issuer=NONE disables issuer checks and is not allowed.
*/}}
{{- define "feedbox.validateSso" -}}
{{- if not .Values.sso.jwtPublicKeyLocation -}}
{{- fail "sso.jwtPublicKeyLocation is required when sso.enabled is true." -}}
{{- end }}
{{- if not .Values.sso.jwtIssuer -}}
{{- fail "sso.jwtIssuer is required when sso.enabled is true (do not use NONE)." -}}
{{- end }}
{{- if eq .Values.sso.jwtIssuer "NONE" -}}
{{- fail "sso.jwtIssuer must not be NONE — set the real IdP issuer URL." -}}
{{- end }}
{{- if not .Values.sso.jwtAudience -}}
{{- fail "sso.jwtAudience is required when sso.enabled is true (usually the OAuth client id)." -}}
{{- end }}
{{- if not .Values.sso.clientId -}}
{{- fail "sso.clientId is required when sso.enabled is true." -}}
{{- end }}
{{- end }}
