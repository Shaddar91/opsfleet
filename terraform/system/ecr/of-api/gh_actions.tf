#of-api's pipeline: every value its workflow reads as an Actions secret, then the workflow itself, committed to the default branch.

module "api_actions" {
  source = "../../../modules/github/actions-secrets-1.0"

  repository = data.github_repository.api.name
  secrets = {
    AWS_ROLE_ARN   = module.ci_role.role_arn
    AWS_REGION     = var.region
    ECR_REPOSITORY = module.ecr.repository_url
  }
}

module "api_workflow" {
  source = "../../../modules/github/repository-files-1.0"

  repository = data.github_repository.api.name
  branch     = data.github_repository.api.default_branch
  files = {
    ".github/workflows/ci.yml" = file("${path.module}/files/workflows/of-api.yml")
  }

  #the commit starts a run on the default branch, which needs every secret above
  depends_on = [module.api_actions]
}
