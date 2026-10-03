#Same-tier ALB stacks' state: the ip target group each binding fills and the ALB security group admitted to the Traefik pods.

data "terraform_remote_state" "edge" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.environment}/edge/edge.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

data "terraform_remote_state" "internal_alb" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.environment}/internal-alb/internal-alb.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  albs = {
    public = {
      target_group_arn  = data.terraform_remote_state.edge.outputs.ingress_target_group_arn
      security_group_id = data.terraform_remote_state.edge.outputs.alb_security_group_id
    }
    internal = {
      target_group_arn  = data.terraform_remote_state.internal_alb.outputs.internal_ingress_target_group_arn
      security_group_id = data.terraform_remote_state.internal_alb.outputs.security_group_id
    }
  }
}
