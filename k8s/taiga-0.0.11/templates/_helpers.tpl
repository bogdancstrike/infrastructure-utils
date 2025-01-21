{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "taiga.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "taiga.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "taiga.mariadb.fullname" -}}
{{- printf "%s-%s" .Release.Name "mariadb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "taiga.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "taiga.labels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}
helm.sh/chart: {{ template "taiga.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{/*
Common labels
*/}}
{{- define "taiga.front.labels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-front
helm.sh/chart: {{ template "taiga.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{- define "taiga.back.labels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-back
helm.sh/chart: {{ template "taiga.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{- define "taiga.gateway.labels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-gateway
helm.sh/chart: {{ template "taiga.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{- define "taiga.events.labels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-events
helm.sh/chart: {{ template "taiga.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{- define "taiga.protected.labels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-protected
helm.sh/chart: {{ template "taiga.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Return  the proper Storage Class
*/}}
{{- define "taiga.storageClass" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
*/}}
{{- if .Values.global -}}
    {{- if .Values.global.storageClass -}}
        {{- if (eq "-" .Values.global.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .Values.global.storageClass -}}
        {{- end -}}
    {{- else -}}
        {{- if .Values.persistence.storageClass -}}
              {{- if (eq "-" .Values.persistence.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else }}
                  {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.persistence.storageClass -}}
        {{- if (eq "-" .Values.persistence.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "taiga.deployment.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "taiga.ingress.apiVersion" -}}
{{- if semverCompare "<1.15-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "taiga.matchLabels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
back
*/}}
{{- define "taiga.back.matchLabels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-back
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
front
*/}}
{{- define "taiga.front.matchLabels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-front
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
gateway
*/}}
{{- define "taiga.gateway.matchLabels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-gateway
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
events
*/}}
{{- define "taiga.events.matchLabels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-events
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
events
*/}}
{{- define "taiga.protected.matchLabels" -}}
app.kubernetes.io/name: {{ template "taiga.name" . }}-protected
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
Renders a value that contains template.
Usage:
{{ include "taiga.tplValue" (dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "taiga.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return the proper Taiga image name
*/}}
{{- define "taiga.back.image" -}}
{{- $registryName := .Values.back.image.registry -}}
{{- $repositoryName := .Values.back.image.repository -}}
{{- $tag := .Values.back.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Taiga image name
*/}}
{{- define "taiga.async.image" -}}
{{- $registryName := .Values.async.image.registry -}}
{{- $repositoryName := .Values.async.image.repository -}}
{{- $tag := .Values.async.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Taiga image name
*/}}
{{- define "taiga.protected.image" -}}
{{- $registryName := .Values.protected.image.registry -}}
{{- $repositoryName := .Values.protected.image.repository -}}
{{- $tag := .Values.protected.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Taiga image name
*/}}
{{- define "taiga.gateway.image" -}}
{{- $registryName := .Values.gateway.image.registry -}}
{{- $repositoryName := .Values.gateway.image.repository -}}
{{- $tag := .Values.gateway.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}



{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "taiga.back.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}

  {{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}

{{- else if .Values.back.image.pullSecrets }}

imagePullSecrets:
{{- range .Values.back.image.pullSecrets }}
  - name: {{ . }}
{{- end }}

{{- end -}}

{{- else if .Values.back.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.back.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "taiga.async.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}

  {{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}

{{- else if .Values.async.image.pullSecrets }}

imagePullSecrets:
{{- range .Values.async.image.pullSecrets }}
  - name: {{ . }}
{{- end }}

{{- end -}}

{{- else if .Values.async.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.async.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "taiga.protected.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}

  {{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}

{{- else if .Values.protected.image.pullSecrets }}

imagePullSecrets:
{{- range .Values.protected.image.pullSecrets }}
  - name: {{ . }}
{{- end }}

{{- end -}}

{{- else if .Values.protected.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.protected.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}


{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "taiga.front.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}

  {{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}

{{- else if .Values.front.image.pullSecrets }}

imagePullSecrets:
{{- range .Values.front.image.pullSecrets }}
  - name: {{ . }}
{{- end }}

{{- end -}}

{{- else if .Values.front.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.front.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}


{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "taiga.gateway.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}

  {{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}

{{- else if .Values.gateway.image.pullSecrets }}

imagePullSecrets:
{{- range .Values.gateway.image.pullSecrets }}
  - name: {{ . }}
{{- end }}

{{- end -}}

{{- else if .Values.gateway.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.gateway.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}


{{/*
Return the proper Taiga Events image name
*/}}
{{- define "taiga.events.image" -}}
{{- $registryName := .Values.events.image.registry -}}
{{- $repositoryName := .Values.events.image.repository -}}
{{- $tag := .Values.events.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "taiga.events.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}

  {{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}

{{- else if .Values.events.image.pullSecrets }}

imagePullSecrets:
{{- range .Values.events.image.pullSecrets }}
  - name: {{ . }}
{{- end }}

{{- end -}}

{{- else if .Values.events.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.events.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "taiga.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "taiga.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}





{{/*
Return the proper Taiga image name
*/}}
{{- define "taiga.front.image" -}}
{{- $registryName := .Values.front.image.registry -}}
{{- $repositoryName := .Values.front.image.repository -}}
{{- $tag := .Values.front.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Create the http taiga url
*/}}
{{- define "taiga.url" -}}
{{- if .Values.ingress.tls }}
{{- printf "https://%s" .Values.ingress.hostname }}
{{- else }}
{{- printf "http://%s" .Values.ingress.hostname }}
{{- end }}
{{- end -}}

{{/*
Create the websockets taiga url
*/}}
{{- define "taiga.websockets" -}}
{{- printf "ws://%s" .Values.ingress.hostname }}
{{- end -}}
