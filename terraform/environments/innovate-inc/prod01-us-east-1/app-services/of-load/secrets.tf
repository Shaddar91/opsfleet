#of-load settings in Secrets Manager as <environment>-<application>, the name the chart's SecretProviderClass pulls.

module "app_secret" {
  source        = "../../../../../modules/secrets-manager/sm-03"
  manage_values = true

  environment = var.environment
  application = var.application
  description = "of-load settings: the of-api URL tokens are checked against, allowed browser origin"
  secrets = {
    OF_API_URL           = local.of_api_url
    CORS_ALLOWED_ORIGINS = local.web_origin
  }
}
