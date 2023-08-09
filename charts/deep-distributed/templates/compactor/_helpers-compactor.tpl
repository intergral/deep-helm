{{/*
compactor imagePullSecrets
*/}}
{{- define "deep.compactorImagePullSecrets" -}}
{{- $dict := dict "component" .Values.compactor.image "global" .Values.global.image -}}
{{- include "deep.imagePullSecrets" $dict -}}
{{- end }}
