resource "aws_eks_access_entry" "main" {
  for_each          = var.access_entries
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = each.value.principal_arn
  type              = each.value.type
  kubernetes_groups = each.value.kubernetes_groups
  user_name         = each.value.user_name

  lifecycle {
    precondition {
      condition     = each.value.principal_arn != var.node_role_arn
      error_message = "Access entry ${each.key} uses node_role_arn: EKS already maps the managed node group role, and one ARN fits in one access entry only. Give Karpenter its own role."
    }
  }
}

resource "aws_eks_access_policy_association" "main" {
  for_each      = local.access_policy_associations
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.main[each.value.entry].principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = each.value.access_scope.namespaces
  }
}
