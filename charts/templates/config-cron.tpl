apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: {{ .Values.configCron.name }}
  namespace: cloudanix
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: config-cron-sa
          imagePullSecrets:
            - name: registrykey
          containers:
          - name: config-cron
            image: {{ .Values.configCron.image }}
            imagePullPolicy: Always
            volumeMounts:
            - name: config-volume
              mountPath: /etc/config.yaml
              subPath: config.yaml
          volumes:
            - name: config-volume
              configMap:
                name: config-cron-cm
          restartPolicy: Never

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: config-cron-cm
  namespace: cloudanix
data:
  config.yaml: |
    config-url: {{ required "A valid URL is required!" .Values.configCron.configURL }}
    falco-sidekick:
      deploy-name: {{ .Values.falcoSidekick.name }}
      configMap-name: {{ .Values.falcoSidekick.configMapName }}
      namespace: cloudanix
    informer:
      deploy-name: {{ .Values.cloudanixInformer.name }}
      configMap-name: {{ .Values.cloudanixInformer.configMapName }}
      namespace: cloudanix
    falco:
      daemon-name: {{ .Release.Name }}-falco
      configMap-name: {{ .Release.Name }}-falco-rules
---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: config-cron-sa
  namespace: cloudanix

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: config-cron-role
  namespace: cloudanix
rules:
- apiGroups: ["","apps","batch"]
  resources: ["deployments","daemonsets","configmaps"]
  verbs: ["get", "watch", "list", "update", "patch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: config-cron
  namespace: cloudanix
subjects:
- kind: ServiceAccount
  name: config-cron-sa
  namespace: cloudanix
roleRef:
  kind: ClusterRole
  name: config-cron-role
  apiGroup: rbac.authorization.k8s.io
