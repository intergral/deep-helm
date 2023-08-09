{{/*
ingester imagePullSecrets
*/}}
{{- define "deep.ingesterImagePullSecrets" -}}
{{- $dict := dict "component" .Values.ingester.image "global" .Values.global.image -}}
{{- include "deep.imagePullSecrets" $dict -}}
{{- end }}
