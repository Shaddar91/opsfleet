#EKS access for the repos whose CI deploys to the cluster: a STANDARD access entry per role and AmazonEKSEditPolicy scoped to one
#namespace, which the eks-components namespaces stack creates.

locals {
  cluster_namespaces = { for repo, namespace in { "of-helm" = "of" } : repo => namespace if contains(var.repos, repo) }
}

resource "aws_eks_access_entry" "ci" {
  for_each = local.cluster_namespaces

  cluster_name  = local.cluster_name
  principal_arn = module.role[each.key].role_arn
  type          = "STANDARD"
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
