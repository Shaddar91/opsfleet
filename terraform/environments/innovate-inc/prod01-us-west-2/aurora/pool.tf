#RDS Proxy in front of the cluster, in the private subnets so it reaches Secrets Manager through the NAT gateway; admits the VPC on 5432 and publishes <name>-pool.

module "pool" {
  source = "../../../../modules/rds/pool-1.2.1"

  environment   = var.environment
  application   = var.application
  engine_family = "POSTGRESQL"

  vpc_id                   = local.vpc_id
  vpc_subnet_ids           = local.private_subnets
  db_cluster_identifier    = module.aurora.cluster_identifier
  db_port                  = module.aurora.port
  target_security_group_id = module.aurora.security_group_id
  auth                     = [{ secret_arn = module.database_secret.arn }]
  allowed_cidr_blocks      = [local.vpc_cidr]
  internal_dns             = local.internal_dns

  depends_on = [module.aurora]
}
