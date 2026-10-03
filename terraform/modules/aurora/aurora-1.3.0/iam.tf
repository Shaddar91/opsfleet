#Enhanced Monitoring role, created only when monitoring_interval is above 0 and no monitoring_role is given.

module "monitoring_role" {
  count       = local.create_monitoring_role ? 1 : 0
  source      = "../../iam/role"
  name        = local.monitoring_role_name
  aws_service = "monitoring.rds.amazonaws.com"
  policy_list = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
}
