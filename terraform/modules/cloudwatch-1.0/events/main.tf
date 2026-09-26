resource "aws_cloudwatch_event_rule" "pattern" {
  count = var.pattern_or_schedule == "pattern" ? 1 : 0
  name = var.rule_name
  event_pattern = var.pattern
}
resource "aws_cloudwatch_event_rule" "schedule" {
  count = var.pattern_or_schedule == "schedule" ? 1 : 0
  name = var.rule_name
  schedule_expression = var.schedule
}
resource "aws_cloudwatch_event_target" "main" {
  count = length(var.targets)
  rule = var.pattern_or_schedule == "pattern" ? aws_cloudwatch_event_rule.pattern[0].name : aws_cloudwatch_event_rule.schedule[0].name
  arn = var.targets[count.index]
  input = var.input
  role_arn = var.role_arn
}