#States of-launch reads: the same-tier network and edge, the system buckets, image repositories and GitHub OIDC provider, the global frontend and the cluster's Argo CD.

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

locals {
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr        = data.terraform_remote_state.network.outputs.vpc_cidr
  private_subnets = data.terraform_remote_state.network.outputs.private_subnets
  bastion_sg_id   = data.terraform_remote_state.network.outputs.bastion_sg_id
  cluster_name    = data.terraform_remote_state.network.outputs.cluster_name
}

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

locals {
  alb_sg_id              = data.terraform_remote_state.edge.outputs.alb_security_group_id
  alb_https_listener_arn = data.terraform_remote_state.edge.outputs.listener_https_arn
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
  artifact_bucket_name = data.terraform_remote_state.artifact_bucket.outputs.bucket_name
  artifact_bucket_arn  = data.terraform_remote_state.artifact_bucket.outputs.bucket_arn
}

data "terraform_remote_state" "backup_bucket" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/system/s3/backup-bucket/backup-bucket.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  backup_bucket_name = data.terraform_remote_state.backup_bucket.outputs.bucket_name
  backup_bucket_arn  = data.terraform_remote_state.backup_bucket.outputs.bucket_arn
}

data "terraform_remote_state" "ecr_of_launch" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/system/ecr/of-launch/of-launch.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  ecr_of_launch_arn  = data.terraform_remote_state.ecr_of_launch.outputs.repository_arn
  ecr_of_launch_url  = data.terraform_remote_state.ecr_of_launch.outputs.repository_url
  ecr_of_launch_name = data.terraform_remote_state.ecr_of_launch.outputs.repository_name
}

data "terraform_remote_state" "ecr_of_api" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/system/ecr/of-api/of-api.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  ecr_of_api_arn = data.terraform_remote_state.ecr_of_api.outputs.repository_arn
}

data "terraform_remote_state" "frontend" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/innovate-inc/global/frontend/frontend.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  web_bucket_name     = data.terraform_remote_state.frontend.outputs.bucket_name
  web_bucket_arn      = data.terraform_remote_state.frontend.outputs.bucket_arn
  web_distribution_id = data.terraform_remote_state.frontend.outputs.distribution_id
}

data "terraform_remote_state" "argocd" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.environment}/cluster/eks/components/argocd/argocd.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  argocd_url = "https://${data.terraform_remote_state.argocd.outputs.argocd_host}"
}
