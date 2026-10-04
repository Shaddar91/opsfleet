#Automatic trigger: the accelerator reports no healthy endpoint in the primary region for primary_unhealthy_minutes, and EventBridge hands the alarm state change to the function, which acts per on_alarm.

module "primary_unhealthy" {
  source = "../../../../../modules/cloudwatch/metric-alarm-1.0"

  alarm_name          = local.trigger_name
  alarm_description   = "The accelerator sees no healthy ${var.primary_region} endpoint for ${var.primary_unhealthy_minutes} minutes; EventBridge sends the state change to the regional failover function"
  namespace           = "AWS/GlobalAccelerator"
  metric_name         = "HealthyEndpointCount"
  dimensions          = local.primary_endpoint_group_dimensions
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = var.primary_unhealthy_minutes
  datapoints_to_alarm = var.primary_unhealthy_minutes
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  treat_missing_data  = "missing"
}

module "alarm_rule" {
  source = "../../../../../modules/cloudwatch-1.0/events"

  pattern_or_schedule = "pattern"
  rule_name           = local.trigger_name
  pattern             = templatefile("${path.module}/files/event-patterns/alarm-state-change.json", { ALARM_ARN = module.primary_unhealthy.arn })
  targets             = [module.failover.function_arn]
  lambda              = module.failover.function_name
}
