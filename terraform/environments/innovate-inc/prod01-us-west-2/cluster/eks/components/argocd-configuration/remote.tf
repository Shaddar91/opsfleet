#Upstream system/github/of-helm state: the repository the Argo CD applications deploy from.

data "terraform_remote_state" "helm_repo" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/system/github/of-helm/of-helm.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  helm_repo_full_name = data.terraform_remote_state.helm_repo.outputs.repo_full_name
}
