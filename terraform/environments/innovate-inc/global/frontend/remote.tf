#Upstream state the frontend reads: the OIDC provider the CI role trusts, the artifact bucket the CI publishes builds to.

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

data "terraform_remote_state" "artifact_bucket" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/system/s3/artifact-bucket/artifact-bucket.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  github_oidc_provider_arn = data.terraform_remote_state.github_oidc.outputs.provider_arn
  artifact_bucket_name     = data.terraform_remote_state.artifact_bucket.outputs.bucket_name
  artifact_bucket_arn      = data.terraform_remote_state.artifact_bucket.outputs.bucket_arn
}
