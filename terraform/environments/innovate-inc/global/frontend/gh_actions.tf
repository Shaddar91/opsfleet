#of-web's pipeline: every value its workflow reads as an Actions secret, then the workflow itself, committed to the default branch.

module "web_actions" {
  source = "../../../../modules/github/actions-secrets-1.0"

  repository = data.github_repository.web.name
  secrets = merge(local.build_values, {
    AWS_ROLE_ARN               = module.ci_role.role_arn
    AWS_REGION                 = var.region
    WEB_BUCKET                 = module.web_bucket.s3_name
    CLOUDFRONT_DISTRIBUTION_ID = module.cloudfront.id
    ARTIFACT_BUCKET            = local.artifact_bucket_name
    ARTIFACT_PREFIX            = var.artifact_prefix
    SNYK_TOKEN                 = var.snyk_token
  })
}

module "web_workflow" {
  source = "../../../../modules/github/repository-files-1.0"

  repository = data.github_repository.web.name
  branch     = data.github_repository.web.default_branch
  files = {
    ".github/workflows/ci.yml" = templatefile("${path.module}/files/workflows/of-web.yml", {
      VITE_KEYS = sort(nonsensitive(keys(local.build_values)))
    })
    #npm only: a github-actions entry would open pin bumps on ci.yml, which this stack overwrites
    ".github/dependabot.yml" = file("${path.module}/files/github/dependabot.yml")
  }

  #the commit starts a run on the default branch, which needs every secret above
  depends_on = [module.web_actions]
}
