locals {
  vpc_id           = data.terraform_remote_state.network.outputs.vpc_id
  internal_subnets = data.terraform_remote_state.network.outputs.internal_subnets

  global_cluster_identifier = data.terraform_remote_state.primary.outputs.global_cluster_identifier
  global_writer_endpoint    = data.terraform_remote_state.primary.outputs.global_writer_endpoint
  primary_region            = provider::aws::arn_parse(data.terraform_remote_state.primary.outputs.cluster_arn).region
  engine                    = data.terraform_remote_state.primary.outputs.engine
  engine_version            = data.terraform_remote_state.primary.outputs.engine_version
  port                      = data.terraform_remote_state.primary.outputs.port
  database_name             = data.terraform_remote_state.primary.outputs.database_name
  master_user_secret_arn    = data.terraform_remote_state.primary.outputs.master_user_secret_replica_arns[var.region]
}
