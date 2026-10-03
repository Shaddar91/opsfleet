#One EC2NodeClass per NodePool, named after it, and two NodePools: x86 by default, Graviton opt-in through its taint; destroy runs pools, class, controller, so finalizers drain nodes first.

resource "kubectl_manifest" "ec2nodeclass" {
  for_each = local.node_pool_arch

  yaml_body = templatefile("${path.module}/files/templates/ec2nodeclass.yaml", {
    NODE_ROLE_NAME = local.karpenter_node_role_name
    CLUSTER_NAME   = local.cluster_name
    ENVIRONMENT    = var.environment
    APPLICATION    = var.application
    POOL           = each.key
    ARCH           = each.value
  })
  wait = true

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "nodepool" {
  for_each = local.node_pool_cpu_limits

  yaml_body = templatefile("${path.module}/files/templates/nodepool-${each.key}.yaml", {
    CPU_LIMIT = each.value
  })
  wait = true

  depends_on = [kubectl_manifest.ec2nodeclass]
}
