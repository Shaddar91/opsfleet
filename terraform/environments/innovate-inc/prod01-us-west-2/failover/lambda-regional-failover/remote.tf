#Upstream state the function reads: the of-failover image repository, and both regions' aurora and edge stacks that name what it promotes and dials.

data "terraform_remote_state" "image" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/system/ecr/of-failover/of-failover.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

data "terraform_remote_state" "primary_aurora" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.primary_environment}/aurora/aurora.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

data "terraform_remote_state" "standby_aurora" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.standby_environment}/aurora/aurora.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

data "terraform_remote_state" "primary_edge" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.primary_environment}/edge/edge.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

data "terraform_remote_state" "standby_edge" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.standby_environment}/edge/edge.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  image_repository_url       = data.terraform_remote_state.image.outputs.repository_url
  global_cluster_identifier  = data.terraform_remote_state.primary_aurora.outputs.global_cluster_identifier
  global_cluster_arn         = data.terraform_remote_state.primary_aurora.outputs.global_cluster_arn
  primary_cluster_arn        = data.terraform_remote_state.primary_aurora.outputs.cluster_arn
  standby_cluster_arn        = data.terraform_remote_state.standby_aurora.outputs.cluster_arn
  primary_endpoint_group_arn = data.terraform_remote_state.primary_edge.outputs.global_accelerator_endpoint_group_arn
  standby_endpoint_group_arn = data.terraform_remote_state.standby_edge.outputs.global_accelerator_endpoint_group_arn
}
