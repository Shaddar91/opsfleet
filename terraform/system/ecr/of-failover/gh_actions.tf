#of-failover's pipeline: every value its workflow reads as an Actions secret, then the workflow itself, committed to the default branch.

module "failover_actions" {
  source = "../../../modules/github/actions-secrets-1.0"

  repository = data.github_repository.failover.name
  secrets = {
    AWS_ROLE_ARN   = module.ci_role.role_arn
    AWS_REGION     = var.region
    ECR_REPOSITORY = module.ecr.repository_url
    SNYK_TOKEN     = var.snyk_token
  }
}

module "failover_workflow" {
  source = "../../../modules/github/repository-files-1.0"

  repository = data.github_repository.failover.name
  branch     = data.github_repository.failover.default_branch
  files = {
    ".github/workflows/ci.yml" = templatefile("${path.module}/files/workflows/of-failover.yml", {
      REPOSITORY = data.github_repository.failover.name
    })
    #pip and docker only: a github-actions entry would open pin bumps on ci.yml, which this stack overwrites
    ".github/dependabot.yml" = file("${path.module}/files/github/dependabot.yml")
  }

  #the commit starts a run on the default branch, which needs every secret above
  depends_on = [module.failover_actions]
}
