output "event_rule_arn" {
  value = var.pattern_or_schedule == "pattern" ? aws_cloudwatch_event_rule.pattern[0].arn : aws_cloudwatch_event_rule.schedule[0].arn
}