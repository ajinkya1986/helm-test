apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.falcoSidekick.name }}
  namespace: cloudanix
  labels:
    {{- with .Values.falcoSidekick.labels }}
    {{ toYaml . | indent 8 }}
    {{- end }}
spec:
  replicas: {{ .Values.falcoSidekick.replicaCount }}
  selector:
    matchLabels:
      {{- with .Values.falcoSidekick.labels }}
      {{ toYaml . | indent 8 }}
      {{- end }}
  template:
    metadata:
      labels:
        {{- with .Values.falcoSidekick.labels }}
        {{ toYaml . | indent 8 }}
        {{- end }}
    spec:
      imagePullSecrets:
        - name: registrykey
      containers:
      - name: falco-sidekick
        image: {{ .Values.falcoSidekick.image }}
        ports:
        - containerPort: 8080
        imagePullPolicy: Always
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config.yaml
          subPath: config.yaml
      volumes:
        - name: config-volume
          configMap:
            name: {{ .Values.falcoSidekick.configMapName }}

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.falcoSidekick.configMapName }}
  namespace: cloudanix
data:
  config.yaml: |
    cloudanix-url: {{ required "A valid URL is required!" .Values.falcoSidekick.cloudanixUrl }}
    buffer-size:  {{ .Values.falcoSidekick.bufferSize }}
    customer-id: {{ required "Customer ID required!" .Values.customerID }}
    cluster-id: {{ required "Cluster ID is required!" .Values.clusterID }}

---

apiVersion: v1
kind: Service
metadata:
  name: falco-sidekick
  namespace: cloudanix
  labels: 
    {{- with .Values.falcoSidekick.labels }}
    {{ toYaml . | indent 8 }}
    {{- end }}
spec:
  ports:
  - port: 8080
    protocol: TCP
  selector:
    app: falco-sidekick
