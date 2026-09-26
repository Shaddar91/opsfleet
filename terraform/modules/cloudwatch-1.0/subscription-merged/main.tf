resource "aws_cloudwatch_log_subscription_filter" "main" {
  count           = (length(coalesce(var.log_group, {})) > 0 && length(coalesce(var.lambda, {})) > 0) ? 1 : 0
  name            = var.filter_name
  log_group_name  = var.log_group["name"]
  filter_pattern  = var.pattern
  destination_arn = var.lambda["arn"]
}

resource "aws_lambda_permission" "main" {
  count         = (length(coalesce(var.log_group, {})) > 0 && length(coalesce(var.lambda, {})) > 0) ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = var.lambda["name"]
  principal     = "logs.${var.region}.amazonaws.com"
  source_arn    = var.log_group["arn"]
}
