locals {
  cluster_identifier = "${var.environment}-${var.application}-aurora-cluster"

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
