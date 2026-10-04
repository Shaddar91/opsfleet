#State written by 1.0, before the resources took count, keeps its place.
moved {
  from = aws_wafv2_web_acl.main
  to   = aws_wafv2_web_acl.main[0]
}

moved {
  from = aws_cloudwatch_log_group.waf
  to   = aws_cloudwatch_log_group.waf[0]
}

moved {
  from = aws_cloudwatch_log_resource_policy.waf
  to   = aws_cloudwatch_log_resource_policy.waf[0]
}

moved {
  from = aws_wafv2_web_acl_logging_configuration.main
  to   = aws_wafv2_web_acl_logging_configuration.main[0]
}
