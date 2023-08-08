{{/*
gossip-ring selector labels
*/}}
{{- define "deep.gossipRingSelectorLabels" -}}
{{ include "deep.selectorLabels" . }}
app.kubernetes.io/part-of: memberlist
{{- end -}}

