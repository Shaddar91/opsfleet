apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: ${jsonencode(name)}
  namespace: ${jsonencode(namespace)}
spec:
  targetGroupARN: ${jsonencode(target_group_arn)}
  targetType: ip
  serviceRef:
    name: ${jsonencode(service_name)}
    port: ${jsonencode(service_port)}
