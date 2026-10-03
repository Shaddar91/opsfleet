#prod01-us Aurora PostgreSQL on the internal subnets, Aurora Standard storage. Database secret in secrets.tf, RDS Proxy in pool.tf, both publish internal names.
#Going global: in terraform.tfvars set create_global_cluster = true and instance_class = "db.r6g.large" (a global database refuses db.t*), apply once, then apply the us-west-2 aurora stack.

module "aurora" {
  source                      = "../../../../modules/aurora/aurora-1.3.1"
  create_global_cluster       = var.create_global_cluster
  create_master_user_secret   = false
  manage_master_user_password = false
  apply_immediately           = true

  environment = var.environment
  application = var.application

  engine         = "aurora-postgresql"
  engine_version = var.engine_version
  family         = data.aws_rds_engine_version.postgresql.parameter_group_family
  port           = 5432

  instance_class       = var.instance_class
  serverlessv2_scaling = var.serverlessv2_scaling
  instance_count       = 1

  database_name      = var.database_name
  master_username    = var.master_username
  master_password_wo = var.aurora_master_password

  vpc_id           = local.vpc_id
  internal_subnets = local.internal_subnets
  internal_dns     = local.internal_dns

  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_period
}
