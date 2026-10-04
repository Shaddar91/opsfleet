data "aws_rds_engine_version" "postgresql" {
  engine  = local.engine
  version = local.engine_version
}

data "aws_subnet" "private" {
  for_each = toset(local.private_subnets)
  id       = each.value
}
