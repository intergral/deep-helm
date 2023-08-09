{{/*
querier imagePullSecrets
*/}}
{{- define "deep.tracepointImagePullSecrets" -}}
{{- $dict := dict "component" .Values.tracepoint.image "global" .Values.global.image -}}
{{- include "deep.imagePullSecrets" $dict -}}
{{- end }}
