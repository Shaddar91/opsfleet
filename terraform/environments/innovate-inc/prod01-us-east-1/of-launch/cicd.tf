#CodeDeploy application and group for the host, its service role, and the GitHub Actions role (OIDC) the deploy workflow assumes.

module "codedeploy" {
  source                 = "../../../../modules/cicd/codedeploy-03"
  enable_asg_integration = false

  environment  = var.environment
  application  = var.application
  service_role = module.codedeploy_service_role.role.arn
  tag_value    = local.of_launch_01
}

module "codedeploy_service_role" {
  source        = "../../../../modules/iam/role"
  custom_policy = true

  environment = var.environment
  application = "${var.application}-codedeploy"
  aws_service = "codedeploy.amazonaws.com"
  policy_file = file("${path.module}/files/policy_files/codedeploy_service_role.json")
}

module "of_launch_cicd_role" {
  source        = "../../../../modules/iam/role"
  custom_policy = true

  environment = var.environment
  application = "${var.application}-cicd"
  #OIDC sub claims match case-sensitively: owner and repo come from the GitHub API, never from var.github_owner
  assume_role_policy = templatefile("${path.module}/files/policy_files/github_actions_assume_role.json", {
    PROVIDER_ARN = local.github_oidc_provider_arn
    OWNER        = split("/", data.github_repository.of_launch.full_name)[0]
    OWNER_ID     = data.github_user.owner.id
    REPO         = split("/", data.github_repository.of_launch.full_name)[1]
    REPO_ID      = data.github_repository.of_launch.repo_id
    BRANCH       = var.gh_branch
  })
  policy_file = templatefile("${path.module}/files/policy_files/cicd_policy.json", {
    REGION           = var.region
    ACCOUNT_ID       = local.account_id
    ARTIFACT_BUCKET  = local.artifact_bucket_name
    ARTIFACT_PREFIX  = local.artifact_prefix
    CODEDEPLOY_APP   = module.codedeploy.app.name
    DEPLOYMENT_GROUP = module.codedeploy.deployment_group.deployment_group_name
    ECR_ARN          = local.ecr_of_launch_arn
  })
}
