#of-api's GitHub Actions role: OIDC trust for the repo's master branch only, push policy from files/policies/of-api-ci.json.

module "ci_role" {
  source        = "../../../modules/iam/role"
  custom_policy = true

  name = "${var.environment}-${var.api_repository}-ci"
  #OIDC sub claims match case-sensitively: owner and repo come from the GitHub API, never from var.github_owner
  assume_role_policy = templatefile("${path.module}/files/trust/github-oidc.json", {
    PROVIDER_ARN = local.github_oidc_provider_arn
    OWNER        = split("/", data.github_repository.api.full_name)[0]
    OWNER_ID     = data.github_user.owner.id
    REPO         = split("/", data.github_repository.api.full_name)[1]
    REPO_ID      = data.github_repository.api.repo_id
  })
  policy_file = templatefile("${path.module}/files/policies/of-api-ci.json", {
    ECR_REPOSITORY_ARN = module.ecr.repository_arn
  })
}
