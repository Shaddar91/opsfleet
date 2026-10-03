#of-api, the sibling this service checks bearer tokens against; the stack plans only after of-api is applied.

data "terraform_remote_state" "of_api" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.environment}/app-services/of-api/of-api.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  of_api_url = data.terraform_remote_state.of_api.outputs.service_url
}
