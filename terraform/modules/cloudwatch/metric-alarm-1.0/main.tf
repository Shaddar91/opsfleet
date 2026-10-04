#CloudWatch metric alarm on a service or custom metric; its state changes reach EventBridge whether or not actions are set.

resource "aws_cloudwatch_metric_alarm" "main" {
  alarm_name          = var.alarm_name
  alarm_description   = var.alarm_description
  namespace           = var.namespace
  metric_name         = var.metric_name
  dimensions          = var.dimensions
  statistic           = var.statistic
  period              = var.period
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  comparison_operator = var.comparison_operator
  threshold           = var.threshold
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
}
