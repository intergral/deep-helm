{{/*
Expand the name of the chart.
*/}}
{{- define "deep.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "deep.fullname" -}}
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
{{- define "deep.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "deep.labels" -}}
helm.sh/chart: {{ include "deep.chart" .ctx }}
{{ include "deep.selectorLabels" . }}
{{- if .ctx.Chart.AppVersion }}
app.kubernetes.io/version: {{ .ctx.Chart.AppVersion | quote }}
{{- end }}
{{- if .memberlist }}
app.kubernetes.io/part-of: memberlist
{{- end }}
app.kubernetes.io/managed-by: {{ .ctx.Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "deep.selectorLabels" -}}
app.kubernetes.io/name: {{ include "deep.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "deep.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "deep.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Resource name template
*/}}
{{- define "deep.resourceName" -}}
{{ include "deep.fullname" .ctx }}{{- if .component -}}-{{ .component }}{{- end -}}
{{- end -}}

{{/*
Calculate the config from structured and unstructured text input
*/}}
{{- define "deep.calculatedConfig" -}}
{{ tpl (mergeOverwrite (tpl .Values.config.deep . | fromYaml) .Values.config.structuredConfig | toYaml) . }}
{{- end -}}

{{/*
Optional list of imagePullSecrets for Tempo docker images
*/}}
{{- define "deep.imagePullSecrets" -}}
{{- $imagePullSecrets := coalesce .global.pullSecrets .component.pullSecrets -}}
{{- if $imagePullSecrets  -}}
imagePullSecrets:
{{- range $imagePullSecrets }}
  - name: {{ . }}
{{ end }}
{{- end }}
{{- end -}}


{{/*
POD labels
*/}}
{{- define "deep.podLabels" -}}
helm.sh/chart: {{ include "deep.chart" .ctx }}
app.kubernetes.io/name: {{ include "deep.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
app.kubernetes.io/version: {{ .ctx.Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .ctx.Release.Service }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- if .memberlist }}
app.kubernetes.io/part-of: memberlist
{{- end -}}
{{- end -}}

{{/*
Calculate image name based on whether enterprise features are requested.  Fallback to hierarchy handling in `tempo.tempoImage`.
*/}}
{{- define "deep.imageReference" -}}
{{ $deep := .ctx.Values.deep.image }}
{{- $componentSection := include "deep.componentSectionFromName" . }}
{{- if not (hasKey .ctx.Values $componentSection) }}
{{- print "Component section " $componentSection " does not exist" | fail }}
{{- end }}
{{- $component := (index .ctx.Values $componentSection).image | default dict }}
{{- $dict := dict "deep" $deep "component" $component "global" .ctx.Values.global.image "defaultVersion" .ctx.Chart.AppVersion -}}
{{- include "deep.deepImage" $dict -}}
{{- end -}}

{{/*
The volume to mount for tempo configuration
*/}}
{{- define "deep.configVolume" -}}
{{- if eq .Values.config.storageType "Secret" -}}
secret:
  secretName: {{ tpl .Values.config.externalSecretName . }}
{{- else if eq .Values.config.storageType "ConfigMap" -}}
configMap:
  name: {{ tpl .Values.config.externalSecretName . }}
  items:
    - key: "deep.yaml"
      path: "deep.yaml"
{{- end -}}
{{- end -}}

{{/*
The volume to mount for tempo runtime configuration
*/}}
{{- define "deep.runtimeVolume" -}}
configMap:
  name: {{ tpl .Values.overrides.externalRuntimeConfigName . }}
  items:
    - key: "overrides.yaml"
      path: "overrides.yaml"
{{- end -}}

{{/*
Calculate values.yaml section name from component name
Expects the component name in .component on the passed context
*/}}
{{- define "deep.componentSectionFromName" -}}
{{- .component | replace "-" "_" | camelcase | untitle -}}
{{- end -}}

{{/*
Docker image selector for Tempo. Hierachy based on global, component, and tempo values.
*/}}
{{- define "deep.deepImage" -}}
{{- $registry := coalesce .component.registry .global.registry -}}
{{- $repository := coalesce .component.repository .global.repository -}}
{{- $tag := coalesce .component.tag .global.tag .defaultVersion | toString -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}


{{/*
Renders the overrides config
*/}}
{{- define "deep.overridesConfig" -}}
{{ tpl .Values.overrides.overrides . }}
{{- end -}}


{{/*
Return the appropriate apiVersion for HorizontalPodAutoscaler.
*/}}
{{- define "deep.hpa.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "autoscaling/v2") (semverCompare ">=1.23-0" .Capabilities.KubeVersion.Version) -}}
    {{- print "autoscaling/v2" -}}
  {{- else -}}
    {{- print "autoscaling/v2beta1" -}}
  {{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for PodDisruptionBudget.
*/}}
{{- define "deep.pdb.apiVersion" -}}
  {{- if .Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" -}}
    {{- print "policy/v1" -}}
  {{- else -}}
    {{- print "policy/v1beta1" -}}
  {{- end -}}
{{- end -}}
