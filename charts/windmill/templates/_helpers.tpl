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
Service account of a server component (app, indexer, operator): its own
serviceAccountName, else the global one. RBAC bindings must use the same helper as the pod
they serve, so a Role never lands on an account the component does not run as.
Usage: {{ include "windmill.componentServiceAccountName" (dict "root" $ "component" "app") }}
*/}}
{{- define "windmill.componentServiceAccountName" -}}
{{- $component := index .root.Values.windmill .component | default dict -}}
{{- default (include "windmill.serviceAccountName" .root) $component.serviceAccountName -}}
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
Optional pod DNS settings. Component values fall back to the global
windmill.dnsPolicy / windmill.dnsConfig values. Emits nothing when neither is set.
Usage:
{{- with include "windmill.podDns" (dict "root" $ "component" "app" "dnsPolicy" $policy "dnsConfig" $config) }}
{{ . | indent 6 }}
{{- end }}
*/}}
{{- define "windmill.podDns" -}}
{{- $root := .root -}}
{{- $component := .component | default "pod" -}}
{{- $dnsPolicy := default $root.Values.windmill.dnsPolicy .dnsPolicy -}}
{{- $dnsConfig := default dict (default $root.Values.windmill.dnsConfig .dnsConfig) -}}
{{- if and (eq $dnsPolicy "None") (not $dnsConfig.nameservers) -}}
{{- fail (printf "windmill: %s: dnsPolicy \"None\" requires dnsConfig.nameservers" $component) -}}
{{- end -}}
{{- $dns := dict -}}
{{- if $dnsPolicy -}}
{{- $_ := set $dns "dnsPolicy" $dnsPolicy -}}
{{- end -}}
{{- if $dnsConfig -}}
{{- $_ := set $dns "dnsConfig" $dnsConfig -}}
{{- end -}}
{{- if $dns -}}
{{- toYaml $dns -}}
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

{{/*
Name of the secret holding the database url, or empty when the url is only configured as a
literal. Worker groups may point at another instance's database, so their own secret wins.
"source" is the values block the url is configured in, for a component with one of its own
(the hub); it defaults to windmill.
Usage: {{ include "windmill.databaseUrlSecretName" (dict "root" $ "override" $v) }}
*/}}
{{- define "windmill.databaseUrlSecretName" -}}
{{- $override := .override | default dict -}}
{{- $source := .source | default .root.Values.windmill -}}
{{- if $override.databaseUrlSecretName -}}
{{- $override.databaseUrlSecretName -}}
{{- else if $source.databaseSecret -}}
windmill-database
{{- else if $source.databaseUrlSecretName -}}
{{- $source.databaseUrlSecretName -}}
{{- end -}}
{{- end -}}

{{/*
Key within the secret resolved by windmill.databaseUrlSecretName.
*/}}
{{- define "windmill.databaseUrlSecretKey" -}}
{{- $override := .override | default dict -}}
{{- $source := .source | default .root.Values.windmill -}}
{{- if $override.databaseUrlSecretName -}}
{{- default "url" $override.databaseUrlSecretKey -}}
{{- else if $source.databaseSecret -}}
url
{{- else if $source.databaseUrlSecretName -}}
{{- default "url" $source.databaseUrlSecretKey -}}
{{- end -}}
{{- end -}}

{{/*
Non-empty for a worker group in agent mode. An agent worker reaches the database through the
API only, so it gets no database url in any form: a job on that worker has nothing to read.
*/}}
{{- define "windmill.isAgentWorker" -}}
{{- if eq (toString (.override | default dict).mode) "agent" -}}true{{- end -}}
{{- end -}}

{{/*
Database url env entry for a component. With databaseUrlAsFile the connection string is read
from a mounted secret file and no DATABASE_URL is rendered at all, so it never appears in the
pod spec. Both the server and the hub prefer DATABASE_URL_FILE over DATABASE_URL. The switch
is read off "source", so the hub opts in separately: it is a separately versioned image, and
one too old to read the file would see no database setting at all.
Usage: {{- include "windmill.databaseUrlEnv" (dict "root" $ "override" $v) | nindent 8 }}
*/}}
{{- define "windmill.databaseUrlEnv" -}}
{{- $source := .source | default .root.Values.windmill -}}
{{- $secretName := include "windmill.databaseUrlSecretName" . -}}
{{- if include "windmill.isAgentWorker" . -}}
{{- else if $source.databaseUrlAsFile -}}
{{- if not (hasPrefix "/" .root.Values.windmill.databaseUrlFilePath) -}}
{{- fail "windmill.databaseUrlFilePath must be an absolute path: its directory becomes the mount point" -}}
{{- end -}}
- name: "DATABASE_URL_FILE"
  value: "{{ .root.Values.windmill.databaseUrlFilePath }}"
{{- else if $secretName }}
- name: "DATABASE_URL"
  valueFrom:
    secretKeyRef:
      name: "{{ $secretName }}"
      key: "{{ include "windmill.databaseUrlSecretKey" . }}"
{{- else }}
- name: "DATABASE_URL"
  value: "{{ $source.databaseUrl }}"
{{- end -}}
{{- end -}}

{{/*
Volume mount for the database url file. Renders nothing when the url is not in a secret:
the file is then supplied by the deployment itself (an init container, a CSI driver), and
mounting anything here would collide with the volume it already mounts at that path.
*/}}
{{- define "windmill.databaseUrlVolumeMount" -}}
{{- $source := .source | default .root.Values.windmill -}}
{{- if and $source.databaseUrlAsFile (include "windmill.databaseUrlSecretName" .) (not (include "windmill.isAgentWorker" .)) -}}
- name: windmill-database-url
  mountPath: {{ dir .root.Values.windmill.databaseUrlFilePath | quote }}
  readOnly: true
{{- end -}}
{{- end -}}

{{/*
Volume projecting the database url secret at databaseUrlFilePath. The key is projected onto
a fixed filename so the path stays the one the operator configured, whatever the secret key
is called.
*/}}
{{- define "windmill.databaseUrlVolume" -}}
{{- $source := .source | default .root.Values.windmill -}}
{{- if and $source.databaseUrlAsFile (include "windmill.databaseUrlSecretName" .) (not (include "windmill.isAgentWorker" .)) -}}
- name: windmill-database-url
  secret:
    secretName: {{ include "windmill.databaseUrlSecretName" . | quote }}
    defaultMode: {{ .root.Values.windmill.databaseUrlFileMode }}
    items:
      - key: {{ include "windmill.databaseUrlSecretKey" . | quote }}
        path: {{ base .root.Values.windmill.databaseUrlFilePath | quote }}
{{- end -}}
{{- end -}}

{{/*
Whether the cluster has the appArmorProfile field (Kubernetes 1.30+). Older clusters only
read the AppArmor profile from a pod annotation.
*/}}
{{- define "windmill.hasAppArmorField" -}}
{{- if semverCompare ">=1.30-0" .Capabilities.KubeVersion.Version -}}true{{- end -}}
{{- end -}}

{{/*
Container security context of a worker group whose isolationSecurity is set: the least a
worker needs to run nsjail without privileged. A profile named in localhostProfiles is used
as a Localhost profile, otherwise that layer is Unconfined, since the runtime default
blocks nsjail. Keys of the group's own security contexts replace the generated ones.
*/}}
{{- define "windmill.workerIsolationSecurityContext" -}}
{{- $v := .group -}}
{{- $profiles := default dict $v.localhostProfiles -}}
{{- $ctx := dict "allowPrivilegeEscalation" false -}}
{{- if eq $v.isolationSecurity "capabilities" -}}
{{- $_ := set $ctx "runAsUser" 0 -}}
{{- $_ := set $ctx "capabilities" (dict "drop" (list "ALL") "add" (list "SYS_ADMIN" "SETPCAP" "SYS_RESOURCE")) -}}
{{- else -}}
{{- $_ := set $ctx "runAsUser" 1000 -}}
{{- $_ := set $ctx "runAsGroup" 1000 -}}
{{- $_ := set $ctx "runAsNonRoot" true -}}
{{- $_ := set $ctx "capabilities" (dict "drop" (list "ALL")) -}}
{{- $_ := set $ctx "procMount" "Unmasked" -}}
{{- end -}}
{{- if $profiles.seccomp -}}
{{- $_ := set $ctx "seccompProfile" (dict "type" "Localhost" "localhostProfile" $profiles.seccomp) -}}
{{- else -}}
{{- $_ := set $ctx "seccompProfile" (dict "type" "Unconfined") -}}
{{- end -}}
{{- if include "windmill.hasAppArmorField" .root -}}
{{- if $profiles.appArmor -}}
{{- $_ := set $ctx "appArmorProfile" (dict "type" "Localhost" "localhostProfile" $profiles.appArmor) -}}
{{- else -}}
{{- $_ := set $ctx "appArmorProfile" (dict "type" "Unconfined") -}}
{{- end -}}
{{- end -}}
{{- range $override := list $v.securityContext $v.containerSecurityContext -}}
{{- range $key, $value := (default dict $override) -}}
{{- $_ := set $ctx $key $value -}}
{{- end -}}
{{- end -}}
{{- toYaml $ctx -}}
{{- end -}}

{{/*   Routing exclusivity check   */}}
{{- if and .Values.httproute.enabled .Values.ingress.enabled }}
{{- fail "Both ingress.enabled and httproute.enabled are true. Disable one to avoid conflicts." }}
{{- end }}