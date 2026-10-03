#EKS access for the deploy role: one STANDARD entry, AmazonEKSEditPolicy scoped to var.namespaces; no cluster-wide rights.

resource "aws_eks_access_entry" "deploy" {
  cluster_name  = local.cluster_name
  principal_arn = module.deploy_role.role_arn
  type          = "STANDARD"

  #role_arn carries no edge to the policy attachments: attach before, detach after the access entry
  depends_on = [module.deploy_role]
}

resource "aws_eks_access_policy_association" "deploy" {
  cluster_name  = local.cluster_name
  principal_arn = aws_eks_access_entry.deploy.principal_arn
  policy_arn    = "arn:${local.partition}:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = var.namespaces
  }
}
