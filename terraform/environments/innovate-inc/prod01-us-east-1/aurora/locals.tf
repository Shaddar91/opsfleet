locals {
  vpc_id           = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr         = data.terraform_remote_state.network.outputs.vpc_cidr
  internal_subnets = data.terraform_remote_state.network.outputs.internal_subnets
  private_subnets  = data.terraform_remote_state.network.outputs.private_subnets

  internal_dns    = { zone_id = local.internal_zone_id, name = "${var.environment}-${var.application}" }
  internal_domain = trimsuffix(local.internal_zone_domain_name, ".")
  db_host         = "${local.internal_dns.name}-pool.${local.internal_domain}"
  db_reader_host  = "${local.internal_dns.name}-ro.${local.internal_domain}"
}
