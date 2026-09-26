resource "aws_lambda_permission" "main" {
  count = (var.lambda != null ? 1 : 0)
  action = "lambda:InvokeFunction"
  function_name = var.lambda
  principal = "events.amazonaws.com"
  source_arn = var.pattern_or_schedule == "pattern" ? aws_cloudwatch_event_rule.pattern[0].arn : aws_cloudwatch_event_rule.schedule[0].arn
}