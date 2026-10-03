#KEDA: scales a Deployment on the ALB requests per minute of its target group; the per-app part is a ScaledObject in the app chart (of-api keda-scaledobject.yaml).

resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  version          = var.chart_version
  namespace        = local.namespace
  create_namespace = true
  values = [templatefile("${path.module}/files/values/keda.yaml", {
    SERVICE_ACCOUNT = local.service_account
  })]

  depends_on = [aws_eks_pod_identity_association.keda]
}
