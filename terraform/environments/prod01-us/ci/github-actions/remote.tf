#Same-tier roles stack state: each repo's CI role ARN, the AWS_ROLE_ARN secret value.

data "terraform_remote_state" "roles" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "terraform/environments/${var.environment}/ci/roles/roles.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  role_arns = data.terraform_remote_state.roles.outputs.role_arns
}
