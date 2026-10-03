#of-load's pipeline: every value its workflow reads as an Actions secret, then the workflow itself, committed to the default branch.

module "load_actions" {
  source = "../../../modules/github/actions-secrets-1.0"

  repository = data.github_repository.load.name
  secrets = {
    AWS_ROLE_ARN   = module.ci_role.role_arn
    AWS_REGION     = var.region
    ECR_REPOSITORY = module.ecr.repository_url
  }
}

module "load_workflow" {
  source = "../../../modules/github/repository-files-1.0"

  repository = data.github_repository.load.name
  branch     = data.github_repository.load.default_branch
  files = {
    ".github/workflows/ci.yml" = file("${path.module}/files/workflows/of-load.yml")
  }

  #the commit starts a run on the default branch, which needs every secret above
  depends_on = [module.load_actions]
}
