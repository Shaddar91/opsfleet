#Aurora state of this region: the database secret the pods read and the Pod Identity role may open; the stack plans only after aurora is applied.

data "terraform_remote_state" "aurora" {
  backend = "s3"
  config = {
    bucket                      = local.state_bucket
    key                         = "${local.state_key_prefix}/environments/${var.environment}/aurora/aurora.tfstate"
    region                      = local.state_bucket_region
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {
  db_secret_arn  = data.terraform_remote_state.aurora.outputs.database_secret_arn
  db_secret_name = data.terraform_remote_state.aurora.outputs.database_secret_name
}
