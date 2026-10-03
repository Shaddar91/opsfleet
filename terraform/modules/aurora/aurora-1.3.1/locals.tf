locals {
  cluster_identifier        = "${var.environment}-${var.application}-aurora-cluster"
  global_cluster_identifier = "${var.environment}-${var.application}-aurora-global"

  master_user_secret_name      = "${var.environment}-${var.application}-aurora-master"
  master_password              = var.create_master_user_secret ? ephemeral.aws_secretsmanager_random_password.master[0].random_password : var.master_password_wo
  master_user_secret_arn       = one(aws_secretsmanager_secret.master[*].arn)
  master_user_secret_arn_parts = one([for arn in aws_secretsmanager_secret.master[*].arn : provider::aws::arn_parse(arn)])
  master_user_secret_replica_arns = {
    for region in var.master_user_secret_replica_regions : region => provider::aws::arn_build(
      local.master_user_secret_arn_parts.partition,
      local.master_user_secret_arn_parts.service,
      region,
      local.master_user_secret_arn_parts.account_id,
      local.master_user_secret_arn_parts.resource
    ) if var.create_master_user_secret
  }

  create_monitoring_role = var.monitoring_interval > 0 && var.monitoring_role == null
  monitoring_role_name   = "${var.environment}-${var.application}-aurora-monitoring"
  monitoring_role_arn    = var.monitoring_interval == 0 ? null : (local.create_monitoring_role ? module.monitoring_role[0].role_arn : var.monitoring_role.arn)

  instance_identifiers = [for i in range(var.instance_count) : "${var.environment}-${var.application}-aurora-instance-${i + 1}"]
  instance_class       = var.instance_class != null ? var.instance_class : (var.serverlessv2_scaling != null ? "db.serverless" : null)
  #Explicit default group: null keeps the last group (Optional+Computed), so dropping instance_parameters could not delete it.
  instance_parameter_group_name = var.instance_parameters == null ? "default.${var.family}" : aws_db_parameter_group.instance[0].name

  internal_dns_name = var.internal_dns == null ? null : coalesce(var.internal_dns.name, var.application)
  internal_records = var.internal_dns == null ? {} : {
    primary = { name = local.internal_dns_name, target = aws_rds_cluster.main.endpoint }
    ro      = { name = "${local.internal_dns_name}-ro", target = aws_rds_cluster.main.reader_endpoint }
  }
}
