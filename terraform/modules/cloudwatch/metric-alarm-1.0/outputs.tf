output "arn" {
  description = "Alarm ARN, the resource an EventBridge pattern filters on"
  value       = aws_cloudwatch_metric_alarm.main.arn
}

output "name" {
  description = "Alarm name"
  value       = aws_cloudwatch_metric_alarm.main.alarm_name
}
