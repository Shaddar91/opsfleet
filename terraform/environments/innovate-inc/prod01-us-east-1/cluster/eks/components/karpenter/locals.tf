locals {
  namespace        = "kube-system"
  chart_repository = "oci://public.ecr.aws/karpenter"

  node_pool_cpu_limits = {
    x86      = var.x86_cpu_limit
    graviton = var.graviton_cpu_limit
  }
}
