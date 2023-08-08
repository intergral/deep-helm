{{/*
distributor imagePullSecrets
*/}}
{{- define "deep.distributorImagePullSecrets" -}}
{{- $dict := dict "component" .Values.distributor.image "global" .Values.global.image -}}
{{- include "deep.imagePullSecrets" $dict -}}
{{- end }}