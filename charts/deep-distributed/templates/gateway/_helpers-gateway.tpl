{{/*
gateway auth secret name
*/}}
{{- define "deep.gatewayAuthSecret" -}}
{{ .Values.gateway.basicAuth.existingSecret | default (include "deep.resourceName" (dict "ctx" . "component" "gateway")) }}
{{- end }}


{{/*
gateway image
*/}}
{{- define "deep.gatewayImage" -}}
{{- $dict := dict "component" .ctx.Values.gateway.image "global" .ctx.Values.global.image -}}
{{- include "deep.deepImage" $dict -}}
{{- end }}

{{/*
gateway imagePullSecrets
*/}}
{{- define "deep.gatewayImagePullSecrets" -}}
{{- $dict := dict "component" .Values.gateway.image "global" .Values.global.image "deep" (dict) -}}
{{- include "deep.imagePullSecrets" $dict -}}
{{- end }}


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
