{{/*
Expand the name of the chart.
*/}}
{{- define "windmill.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "windmill.fullname" -}}
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
{{- define "windmill.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "windmill.labels" -}}
helm.sh/chart: {{ include "windmill.chart" . }}
{{ include "windmill.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "windmill.selectorLabels" -}}
app.kubernetes.io/name: {{ include "windmill.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "windmill.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "windmill.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validate controller kind, defaulting to "Deployment"
*/}}
{{- define "validateControllerKind" -}}
{{- $validTypes := list "Deployment" "StatefulSet" -}}
{{- $inputType := default "Deployment" . -}}
{{- if has $inputType $validTypes -}}
{{ $inputType }}
{{- else -}}
{{- fail (printf "Invalid controller type: %s. Must be either Deployment or StatefulSet" $inputType) -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains a template, with scope if present.
Usage:
{{ include "common.tplvalues.render" (dict "value" . "context" $) }}
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}
