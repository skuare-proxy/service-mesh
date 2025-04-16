{{- define "servicemesh.name" -}}
{{- default "service-mesh" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "servicemesh.labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app: "{{ template "servicemesh.name" . }}"
layer: vault
{{- end -}}

{{/* matchLabels */}}
{{- define "servicemesh.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ template "servicemesh.name" . }}"
{{- end -}}