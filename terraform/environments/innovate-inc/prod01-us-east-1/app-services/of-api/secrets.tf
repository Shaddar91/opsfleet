#of-api settings in Secrets Manager as <environment>-<application>, the name the chart's SecretProviderClass pulls; the database settings come from the aurora stack's database secret.

module "app_secret" {
  source        = "../../../../../modules/secrets-manager/sm-03"
  manage_values = true

  environment = var.environment
  application = var.application
  description = "of-api settings: token lifetime, allowed browser origin, the seeded login and its password"
  secrets = {
    TOKEN_TTL_SECONDS    = tostring(var.token_ttl_seconds)
    CORS_ALLOWED_ORIGINS = local.web_origin
    OF_API_USER          = var.seed_user
    OF_API_USER_PASSWORD = var.seed_user_password
  }
}
