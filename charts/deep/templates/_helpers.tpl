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
Calculate the config from structured and unstructured text input
*/}}
{{- define "deep.calculatedConfig" -}}
{{ tpl (mergeOverwrite (tpl .Values.config.deep . | fromYaml) .Values.config.structuredConfig | toYaml) . }}
{{- end -}}

{{/*
Renders the overrides config
*/}}
{{- define "deep.overridesConfig" -}}
{{ tpl .Values.overrides.overrides . }}
{{- end -}}

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
Selector labels
*/}}
{{- define "deep.selectorLabels" -}}
app.kubernetes.io/name: {{ include "deep.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
{{- end }}

{{/*
Resource name template
*/}}
{{- define "deep.resourceName" -}}
{{ include "deep.fullname" .ctx }}{{- if .component -}}-{{ .component }}{{- end -}}
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
Return if ingress is stable.
*/}}
{{- define "deep.ingress.isStable" -}}
{{- eq (include "deep.ingress.apiVersion" .) "networking.k8s.io/v1" }}
{{- end }}


{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "deep.ingress.apiVersion" -}}
{{- if and ($.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) }}
{{- print "networking.k8s.io/v1" }}
{{- else if $.Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" }}
{{- print "networking.k8s.io/v1beta1" }}
{{- else }}
{{- print "extensions/v1beta1" }}
{{- end }}
{{- end }}


{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "deep.ingress.supportsIngressClassName" -}}
{{- or (eq (include "deep.ingress.isStable" .) "true") (and (eq (include "deep.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) }}
{{- end }}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "deep.ingress.supportsPathType" -}}
{{- or (eq (include "deep.ingress.isStable" .) "true") (and (eq (include "deep.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) }}
{{- end }}


{{/*
Cluster name that shows up in dashboard metrics
*/}}
{{- define "deep.clusterName" -}}
{{ (include "deep.calculatedConfig" . | fromYaml).cluster_name | default .Release.Name }}
{{- end -}}