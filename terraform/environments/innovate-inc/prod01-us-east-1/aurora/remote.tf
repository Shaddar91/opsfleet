#Same-tier network stack state: the VPC and the internal subnets the DB subnet group spans.

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.environment}/network/network.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
