apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.cloudanixInformer.name }}
  namespace: cloudanix
  labels:
    {{- with .Values.cloudanixInformer.labels }}
    {{ toYaml . | indent 8 }}
    {{- end }}
spec:
  replicas: 1
  selector:
    matchLabels:
      {{- with .Values.cloudanixInformer.labels }}
      {{ toYaml . | indent 8 }}
      {{- end }}
  template:
    metadata:
      labels:
        {{- with .Values.cloudanixInformer.labels }}
        {{ toYaml . | indent 8 }}
        {{- end }}
    spec:
      serviceAccountName: {{ .Values.cloudanixInformer.serviceAccount }}
      automountServiceAccountToken: true
      containers:
      - name: cloudanix-informer
        image: {{ .Values.cloudanixInformer.image }}
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
            name: {{ .Values.cloudanixInformer.configMapName }}
      terminationGracePeriodSeconds: 60
---

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.cloudanixInformer.configMapName }}
  namespace: cloudanix
data:
  config.yaml: |
    cloudanix-url: {{ required "A valid URL is required!" .Values.cloudanixInformer.cloudanixUrl }}
    buffer-size:  {{ .Values.cloudanixInformer.bufferSize }}
    customer-id: {{ required "Customer ID required!" .Values.customerID }}
    cluster-id: {{ required "Cluster ID is required!" .Values.clusterID }}
---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Values.cloudanixInformer.serviceAccount }}
  namespace: cloudanix

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ .Values.cloudanixInformer.clusterRole }}
  namespace: cloudanix
rules:
- apiGroups: ["","apps","batch"]
  resources: ["services","deployments","cronjobs","statefulsets","daemonsets","nodes","pods"]
  verbs: ["get", "watch", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cloudanix-informer
  namespace: cloudanix
subjects:
- kind: ServiceAccount
  name: {{ .Values.cloudanixInformer.serviceAccount }}
  namespace: cloudanix
roleRef:
  kind: ClusterRole
  name: {{ .Values.cloudanixInformer.clusterRole }}
  apiGroup: rbac.authorization.k8s.io