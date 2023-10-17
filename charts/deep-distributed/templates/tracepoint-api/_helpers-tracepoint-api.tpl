{{/*
querier imagePullSecrets
*/}}
{{- define "deep.tracepointImagePullSecrets" -}}
{{- $dict := dict "component" .Values.tracepointApi.image "global" .Values.global.image -}}
{{- include "deep.imagePullSecrets" $dict -}}
{{- end }}
