{{/*
ingester imagePullSecrets
*/}}
{{- define "deep.queryFrontendImagePullSecrets" -}}
{{- $dict := dict "component" .Values.queryFrontend.image "global" .Values.global.image -}}
{{- include "deep.imagePullSecrets" $dict -}}
{{- end }}
