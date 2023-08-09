{{/*
querier imagePullSecrets
*/}}
{{- define "deep.querierImagePullSecrets" -}}
{{- $dict := dict "component" .Values.querier.image "global" .Values.global.image -}}
{{- include "deep.imagePullSecrets" $dict -}}
{{- end }}
