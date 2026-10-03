locals {
  repo_secrets = {}

  repo_variables = {
    "of-api" = {
      ECR_REPOSITORY = local.ecr_repository_url
    }
    "of-helm" = {
      EKS_CLUSTER_NAME = local.cluster_name
      K8S_NAMESPACE    = "of"
      ECR_REPOSITORY   = local.ecr_repository_url
    }
  }
}
