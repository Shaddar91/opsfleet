#Same-tier github-oidc stack state: the account's GitHub OIDC provider both roles trust.

data "terraform_remote_state" "github_oidc" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/system/iam/github-oidc/github-oidc.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  github_oidc_provider_arn = data.terraform_remote_state.github_oidc.outputs.provider_arn
}
