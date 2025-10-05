{{/*
Expand the name of the chart.
*/}}
{{- define "fast-food.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fast-food.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fast-food.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fast-food.labels" -}}
helm.sh/chart: {{ include "fast-food.chart" . }}
{{ include "fast-food.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
project: soat-tech-challenge
environment: production
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fast-food.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fast-food.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fast-food.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fast-food.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
MySQL labels
*/}}
{{- define "fast-food.mysql.labels" -}}
{{ include "fast-food.labels" . }}
app.kubernetes.io/component: database
{{- end }}

{{/*
MySQL selector labels
*/}}
{{- define "fast-food.mysql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fast-food.name" . }}-mysql
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: database
{{- end }}