#App settings and seed users in Secrets Manager; the host writes them to .env at every start.

module "sm" {
  source = "../../../../modules/secrets-manager/sm-02"

  application = var.application
  environment = var.environment
  description = "of-launch settings"
  secrets     = local.of_launch_secrets
}

module "sm_seed" {
  source = "../../../../modules/secrets-manager/sm-02"

  application = "${var.application}-seed"
  environment = var.environment
  description = "of-launch user credentials (key=username, value=password)"
  secrets     = var.of_launch_seed_users
}

resource "random_password" "of_launch_db_password" {
  length  = 24
  special = false
}

resource "random_password" "of_launch_app_secret_key" {
  length  = 48
  special = false
}
