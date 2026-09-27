#Per repo, by name: the AWS_ROLE_ARN secret and the variables its workflows read, through actions-secrets-1.0.

locals {
  repo_variables = {
    "of-web" = {
      WEB_BUCKET                 = local.web_bucket_name
      CLOUDFRONT_DISTRIBUTION_ID = local.distribution_id
    }
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

module "actions" {
  source   = "../../../../modules/github/actions-secrets-1.0"
  for_each = toset(var.repos)

  repository = each.key
  secrets    = { AWS_ROLE_ARN = local.role_arns[each.key] }
  variables = merge(
    { AWS_REGION = var.region, DEPLOY_ENABLED = var.deploy_enabled },
    lookup(local.repo_variables, each.key, {}),
  )
}
