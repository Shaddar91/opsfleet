#EC2NodeClass default and two NodePools: x86 by default, Graviton opt-in through its taint; destroy runs pools, class, controller, so finalizers drain nodes first.

resource "kubectl_manifest" "ec2nodeclass" {
  yaml_body = templatefile("${path.module}/files/templates/ec2nodeclass.yaml.tpl", {
    node_role_name = local.karpenter_node_role_name
    cluster_name   = local.cluster_name
    environment    = var.environment
    application    = var.application
  })
  wait = true

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "nodepool" {
  for_each = local.node_pool_cpu_limits

  yaml_body = templatefile("${path.module}/files/templates/nodepool-${each.key}.yaml.tpl", {
    cpu_limit = each.value
  })
  wait = true

  depends_on = [kubectl_manifest.ec2nodeclass]
}
