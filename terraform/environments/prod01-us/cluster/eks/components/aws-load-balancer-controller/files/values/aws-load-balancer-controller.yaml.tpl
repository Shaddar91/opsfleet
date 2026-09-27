clusterName: ${jsonencode(cluster_name)}
region: ${jsonencode(region)}
vpcId: ${jsonencode(vpc_id)}
serviceAccount:
  name: ${jsonencode(service_account)}
nodeSelector:
  role: system
enableServiceMutatorWebhook: false
createIngressClassResource: false
