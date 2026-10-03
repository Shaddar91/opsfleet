# keda-1.0

KEDA scales a Deployment on the requests per minute its ALB target group receives, instead of CPU or memory. This module installs KEDA once per cluster; each app adds one ScaledObject in its chart.

Cluster side, this module: the keda Helm release in the `keda` namespace and an operator role with read-only CloudWatch (`files/policies/keda-cloudwatch.json`), bound by EKS Pod Identity. Nothing per app lives here.

App side, the example in the of-api chart (`templates/keda-scaledobject.yaml`), switched on with these values:

```yaml
autoscaling:
  enabled: false          # KEDA owns the HPA; two autoscalers on one Deployment fight
keda:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  requestsPerPodPerMinute: 300
  loadBalancerARN: arn:aws:elasticloadbalancing:...:loadbalancer/app/<name>/<id>   # the edge ALB
targetGroupBinding:
  targetGroupARN: arn:aws:elasticloadbalancing:...:targetgroup/<name>/<id>         # Terraform already passes this
```

Desired pods = requests per minute on the target group / `requestsPerPodPerMinute`, clamped to min and max. ALB numbers reach CloudWatch one to two minutes late, so the first scale-out follows the load by about three minutes; `minReplicas` has to absorb that. The optional `cpuTriggerUtilization` keeps a CPU trigger beside it, KEDA takes the higher of the two.

Order: metrics-server is not needed for the request trigger, only for the optional CPU one. Karpenter adds nodes when the new pods do not fit, as for any other pod.
