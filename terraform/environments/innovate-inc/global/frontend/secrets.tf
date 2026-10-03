#Off: of-web's build values are GitHub Actions secrets on the repo (gh_actions.tf). Kept for a move back to Secrets Manager.

#module "web_build_secret" {
#  source = "../../../../modules/secrets-manager/sm-02"
#
#  environment = var.environment
#  application = "of-web-build"
#  secrets     = merge(var.web_build_values, { VITE_API_BASE_URL = local.api_base_url })
#  description = "of-web build-time values the CI reads over OIDC"
#}
