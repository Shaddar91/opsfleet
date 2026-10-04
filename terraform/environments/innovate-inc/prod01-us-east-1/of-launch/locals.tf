locals {
  name            = "${var.environment}-${var.application}"
  of_launch_01    = "${var.environment}-${var.application}-01"
  fqdn            = "${var.public_subdomain}.${local.public_zone_domain_name}"
  account_id      = data.aws_caller_identity.current.account_id
  artifact_prefix = "${var.environment}/${var.application}"

  of_launch_rule_cidr = [
    { type = "ingress", from_port = 8080, to_port = 8080, protocol = "tcp", cidrs = [local.vpc_cidr] },
    { type = "egress", from_port = 0, to_port = 0, protocol = "-1", cidrs = ["0.0.0.0/0"] },
  ]

  of_launch_template_vars = {
    NODE_NAME            = local.of_launch_01
    AWS_REGION           = var.region
    SECRETS_MANAGER_NAME = module.sm.secrets_manager.name
    SEED_SM_NAME         = module.sm_seed.secrets_manager.name
    PUBLIC_DOMAIN        = local.fqdn
    BACKUP_BUCKET        = local.backup_bucket_name
  }

  #keys are the app's env var names; the host writes them to .env as they are
  of_launch_config = {
    MOCK_MODE              = "false"
    OF_REGION              = var.region
    DB_HOST                = "mysql"
    DB_PORT                = "3306"
    DB_USER                = "root"
    DB_NAME                = "deployment_app"
    TABLE_NAME_USERS       = "users"
    TABLE_NAME_DEPLOYMENTS = "deployments"
    PER_PAGE_DEFAULT       = "10"
    MAX_RECORDS            = "100"
    ARGOCD_OF_URL          = local.argocd_url
    OF_GITHUB_OWNER        = var.github_owner
    OF_ARTIFACT_BUCKET     = local.artifact_bucket_name
    OF_WEB_DEPLOY_BUCKET   = local.web_bucket_name
    OF_WEB_CLOUDFRONT_ID   = local.web_distribution_id
  }

  of_launch_generated = {
    DB_PASSWORD    = random_password.of_launch_db_password.result
    APP_SECRET_KEY = random_password.of_launch_app_secret_key.result
  }

  of_launch_secrets = merge(local.of_launch_config, local.of_launch_generated, var.of_launch_secrets)

  of_launch_github_secrets = {
    OF_LAUNCH_CICD_ROLE        = module.of_launch_cicd_role.role.arn
    OF_LAUNCH_REGION           = var.region
    OF_LAUNCH_ECR_REGISTRY     = split("/", local.ecr_of_launch_url)[0]
    OF_LAUNCH_ECR_REPO         = local.ecr_of_launch_name
    OF_LAUNCH_ARTIFACT_BUCKET  = local.artifact_bucket_name
    OF_LAUNCH_ARTIFACT_PREFIX  = local.artifact_prefix
    OF_LAUNCH_CODEDEPLOY_APP   = module.codedeploy.app.name
    OF_LAUNCH_DEPLOYMENT_GROUP = module.codedeploy.deployment_group.deployment_group_name
  }

  of_launch_repo_files = {
    ".github/workflows/deploy.yml"             = templatefile("${path.module}/files/cicd/workflow.yml", { APPLICATION = var.application })
    ".codedeploy/appspec.yml"                  = file("${path.module}/files/codedeploy/appspec.yml")
    ".codedeploy/docker-compose.yml"           = file("${path.module}/files/codedeploy/docker-compose.yml")
    ".codedeploy/scripts/application_stop.sh"  = file("${path.module}/files/codedeploy/scripts/application_stop.sh")
    ".codedeploy/scripts/before_install.sh"    = file("${path.module}/files/codedeploy/scripts/before_install.sh")
    ".codedeploy/scripts/after_install.sh"     = file("${path.module}/files/codedeploy/scripts/after_install.sh")
    ".codedeploy/scripts/application_start.sh" = file("${path.module}/files/codedeploy/scripts/application_start.sh")
    ".codedeploy/scripts/validate_service.sh"  = file("${path.module}/files/codedeploy/scripts/validate_service.sh")
  }
}
