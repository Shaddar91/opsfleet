#Same-tier karpenter-aws state: the interruption queue the controller reads, which exists only once that stack is applied.

data "terraform_remote_state" "karpenter_aws" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "terraform/environments/${var.environment}/cluster/eks/components/karpenter-aws/karpenter-aws.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  interruption_queue_name = data.terraform_remote_state.karpenter_aws.outputs.queue_name
  controller_role_arn     = data.terraform_remote_state.karpenter_aws.outputs.controller_role_arn
}
