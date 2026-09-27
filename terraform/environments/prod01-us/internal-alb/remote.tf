#Same-tier network stack state: the VPC, its CIDR and the private subnets the internal ALB sits on.

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "terraform/environments/${var.environment}/network/network.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr        = data.terraform_remote_state.network.outputs.vpc_cidr
  private_subnets = data.terraform_remote_state.network.outputs.private_subnets
}
