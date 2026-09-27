resource "aws_eks_addon" "before_compute" {
  for_each                    = local.addons_before_compute
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = local.addon_versions[each.key]
  configuration_values        = each.value.configuration_values
  service_account_role_arn    = each.value.service_account_role_arn
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity == null ? [] : [each.value.pod_identity]
    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }
}

resource "aws_eks_addon" "after_compute" {
  for_each                    = local.addons_after_compute
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = local.addon_versions[each.key]
  configuration_values        = each.value.configuration_values
  service_account_role_arn    = each.value.service_account_role_arn
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity == null ? [] : [each.value.pod_identity]
    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  depends_on = [aws_eks_node_group.main]
}
