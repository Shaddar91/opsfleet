#of-web's GitHub Actions role: OIDC trust for the repo's master branch only, deploy policy from files/policies/of-web-ci.json.

module "ci_role" {
  source        = "../../../../modules/iam/role"
  custom_policy = true

  name = "${var.environment}-${var.web_repository}-ci"
  #OIDC sub claims match case-sensitively: owner and repo come from the GitHub API, never from var.github_owner
  assume_role_policy = templatefile("${path.module}/files/trust/github-oidc.json", {
    PROVIDER_ARN = local.github_oidc_provider_arn
    OWNER        = split("/", data.github_repository.web.full_name)[0]
    OWNER_ID     = data.github_user.owner.id
    REPO         = split("/", data.github_repository.web.full_name)[1]
    REPO_ID      = data.github_repository.web.repo_id
  })
  policy_file = templatefile("${path.module}/files/policies/of-web-ci.json", {
    WEB_BUCKET_ARN      = module.web_bucket.arn
    DISTRIBUTION_ARN    = module.cloudfront.arn
    ARTIFACT_BUCKET_ARN = local.artifact_bucket_arn
    ARTIFACT_PREFIX     = var.artifact_prefix
  })
}
