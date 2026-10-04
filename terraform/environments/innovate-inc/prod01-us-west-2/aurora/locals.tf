locals {
  vpc_id           = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr         = data.terraform_remote_state.network.outputs.vpc_cidr
  internal_subnets = data.terraform_remote_state.network.outputs.internal_subnets
  private_subnets  = data.terraform_remote_state.network.outputs.private_subnets

  global_cluster_identifier = data.terraform_remote_state.primary.outputs.global_cluster_identifier
  global_writer_endpoint    = data.terraform_remote_state.primary.outputs.global_writer_endpoint
  primary_region            = provider::aws::arn_parse(data.terraform_remote_state.primary.outputs.cluster_arn).region
  engine                    = data.terraform_remote_state.primary.outputs.engine
  engine_version            = data.terraform_remote_state.primary.outputs.engine_version
  port                      = data.terraform_remote_state.primary.outputs.port
  database_name             = data.terraform_remote_state.primary.outputs.database_name
  master_username           = data.terraform_remote_state.primary.outputs.master_username

  internal_dns    = { zone_id = local.internal_zone_id, name = "${var.environment}-${var.application}" }
  internal_domain = trimsuffix(local.internal_zone_domain_name, ".")
  db_host         = "${local.internal_dns.name}-pool.${local.internal_domain}"
  db_reader_host  = "${local.internal_dns.name}-ro.${local.internal_domain}"
  backend_db_host = var.write_forwarding ? local.db_reader_host : local.db_host
  backend_cidrs   = var.write_forwarding ? [for s in data.aws_subnet.private : s.cidr_block] : []
}
