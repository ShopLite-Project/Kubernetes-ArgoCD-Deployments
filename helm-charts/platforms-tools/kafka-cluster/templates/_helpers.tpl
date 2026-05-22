{{- define "kafka-cluster.fullname" -}}
{{- default .Chart.Name .Values.cluster.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
