#prod01-us Aurora PostgreSQL global database primary on the internal subnets, master password generated into a secret replicated to the secondary regions.

module "aurora" {
  source                      = "../../../../modules/aurora/aurora-1.3.0"
  create_global_cluster       = true
  create_master_user_secret   = true
  manage_master_user_password = false

  environment = var.environment
  application = var.application

  engine         = "aurora-postgresql"
  engine_version = var.engine_version
  family         = data.aws_rds_engine_version.postgresql.parameter_group_family
  port           = 5432

  instance_class       = var.instance_class
  serverlessv2_scaling = var.serverlessv2_scaling
  instance_count       = 1

  database_name   = var.database_name
  master_username = var.master_username

  master_user_secret_replica_regions = var.master_user_secret_replica_regions

  vpc_id           = local.vpc_id
  internal_subnets = local.internal_subnets

  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_period
}
