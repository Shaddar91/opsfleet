resource "aws_cloudwatch_log_group" "waf" {
  region            = "us-east-1"
  name              = "aws-waf-logs-${local.name}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

resource "aws_cloudwatch_log_resource_policy" "waf" {
  region          = "us-east-1"
  policy_name     = "${local.name}-waf-logs"
  policy_document = data.aws_iam_policy_document.waf_logs.json
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  region                  = "us-east-1"
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn

  dynamic "redacted_fields" {
    for_each = var.redacted_headers
    content {
      single_header {
        name = redacted_fields.value
      }
    }
  }

  depends_on = [aws_cloudwatch_log_resource_policy.waf]
}
