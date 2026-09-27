#Same-tier edge stack state: the ALB the accelerator fronts and the hostname its record carries.

data "terraform_remote_state" "edge" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "terraform/environments/${var.environment}/edge/edge.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  edge_alb_arn = data.terraform_remote_state.edge.outputs.alb_arn
  app_fqdn     = data.terraform_remote_state.edge.outputs.app_fqdn
}
