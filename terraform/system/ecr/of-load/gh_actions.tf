#of-load's pipeline: every value its workflow reads as an Actions secret, then the workflow itself, committed to the default branch.

module "load_actions" {
  source = "../../../modules/github/actions-secrets-1.0"

  repository = data.github_repository.load.name
  secrets = {
    AWS_ROLE_ARN   = module.ci_role.role_arn
    AWS_REGION     = var.region
    ECR_REPOSITORY = module.ecr.repository_url
    SNYK_TOKEN     = var.snyk_token
  }
}

module "load_workflow" {
  source = "../../../modules/github/repository-files-1.0"

  repository = data.github_repository.load.name
  branch     = data.github_repository.load.default_branch
  files = {
    ".github/workflows/ci.yml" = templatefile("${path.module}/files/workflows/of-load.yml", {
      REPOSITORY = data.github_repository.load.name
    })
    #cargo only: a github-actions entry would open pin bumps on ci.yml, which this stack overwrites
    ".github/dependabot.yml"               = file("${path.module}/files/github/dependabot.yml")
    ".github/workflows/release-please.yml" = file("${path.module}/files/workflows/release-please.yml")
    "release-please-config.json"           = file("${path.module}/files/release/release-please-config.json")
    ".release-please-manifest.json"        = file("${path.module}/files/release/release-please-manifest.json")
  }

  #the commit starts a run on the default branch, which needs every secret above
  depends_on = [module.load_actions]
}

#release-please opens its release pull request with GITHUB_TOKEN, which the repository must allow.
module "load_workflow_permissions" {
  source                           = "../../../modules/github/workflow-permissions-1.0"
  can_approve_pull_request_reviews = true

  repository = data.github_repository.load.name
}
