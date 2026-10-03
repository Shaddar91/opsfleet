#EKS access for the repos whose CI deploys to the cluster: a STANDARD entry per role, AmazonEKSEditPolicy scoped to one namespace the namespaces stack creates.

resource "aws_eks_access_entry" "ci" {
  for_each = local.cluster_namespaces

  cluster_name  = local.cluster_name
  principal_arn = module.role[each.key].role_arn
  type          = "STANDARD"

  #role_arn carries no edge to the policy attachments: attach before, detach after the access entry
  depends_on = [module.role]
}

resource "aws_eks_access_policy_association" "ci" {
  for_each = aws_eks_access_entry.ci

  cluster_name  = local.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = [local.cluster_namespaces[each.key]]
  }
}
