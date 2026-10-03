locals {
  cluster_namespaces = { for repo, namespace in { "of-helm" = "of" } : repo => namespace if contains(var.repos, repo) }

  policy_vars = {
    ECR_REPOSITORY_ARN = local.ecr_repository_arn
    CLUSTER_ARN        = local.cluster_arn
  }
}
