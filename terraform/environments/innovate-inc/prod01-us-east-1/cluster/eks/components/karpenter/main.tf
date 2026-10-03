#Karpenter: karpenter-crd owns the CRDs so a chart bump upgrades them, then the controller on the system node group with skip_crds.

resource "helm_release" "karpenter_crd" {
  name             = "karpenter-crd"
  repository       = local.chart_repository
  chart            = "karpenter-crd"
  version          = var.chart_version
  namespace        = local.namespace
  create_namespace = false
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = local.chart_repository
  chart            = "karpenter"
  version          = var.chart_version
  namespace        = local.namespace
  create_namespace = false
  skip_crds        = true
  wait             = true
  values = [templatefile("${path.module}/files/values/karpenter-values.yaml", {
    CLUSTER_NAME            = local.cluster_name
    INTERRUPTION_QUEUE_NAME = local.interruption_queue_name
    REGION                  = var.region
  })]

  depends_on = [helm_release.karpenter_crd]
}
