serviceAccount:
  name: karpenter
nodeSelector:
  kubernetes.io/os: linux
  role: system
settings:
  clusterName: ${cluster_name}
  interruptionQueue: ${interruption_queue_name}
controller:
  env:
    - name: AWS_REGION
      value: ${region}
  resources:
    requests:
      cpu: "1"
      memory: 1Gi
    limits:
      cpu: "1"
      memory: 1Gi
