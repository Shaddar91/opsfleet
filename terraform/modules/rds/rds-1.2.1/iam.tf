#Enhanced Monitoring role, one per instance, created only when monitoring_interval is above 0.

module "monitoring_role" {
  count       = var.monitoring_interval > 0 ? 1 : 0
  source      = "../../iam/role"
  name        = local.monitoring_role_name
  aws_service = "monitoring.rds.amazonaws.com"
  policy_list = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
}
