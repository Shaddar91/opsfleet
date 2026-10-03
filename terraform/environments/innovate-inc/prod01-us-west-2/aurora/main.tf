#prod01-usw2 Aurora PostgreSQL global database secondary on the internal subnets, joined to the primary stack's global cluster.

module "aurora" {
  source                         = "../../../../modules/aurora/aurora-secondary-1.0.0"
  enable_global_write_forwarding = false

  environment = var.environment
  application = var.application

  global_cluster_identifier = local.global_cluster_identifier
  source_region             = local.primary_region

  engine         = local.engine
  engine_version = local.engine_version
  family         = data.aws_rds_engine_version.postgresql.parameter_group_family
  port           = local.port

  instance_class       = var.instance_class
  serverlessv2_scaling = var.serverlessv2_scaling
  instance_count       = 1

  vpc_id           = local.vpc_id
  internal_subnets = local.internal_subnets

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
}
