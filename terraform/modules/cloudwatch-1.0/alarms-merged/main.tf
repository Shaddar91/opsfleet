resource "aws_cloudwatch_log_metric_filter" "main" {
  count          = var.filter ? 1 : 0
  name           = var.filter_name
  pattern        = var.pattern
  log_group_name = var.log_group_name
  metric_transformation {
    name      = var.metric_name
    namespace = var.namespace
    value     = "1"
  }
}
resource "aws_cloudwatch_metric_alarm" "main" {
  alarm_name          = var.alarm_name
  comparison_operator = var.comparison_operator
  evaluation_periods  = "1"
  metric_name         = var.metric_name
  namespace           = var.namespace
  threshold           = var.threshold
  alarm_actions       = var.alarm_actions
  statistic           = "Average"
  period              = var.period
  dimensions          = var.dimensions
  treat_missing_data  = var.treat_missing_data
}