locals {
  name = coalesce(var.name, "${var.environment}-${var.application}-cf-web-acl")

  tags = {
    Name        = local.name
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_wafv2_ip_set" "rate_limit_excluded" {
  count              = length(var.rate_limit_excluded_ips) > 0 ? 1 : 0
  region             = "us-east-1"
  name               = "${local.name}-rate-limit-excluded"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.rate_limit_excluded_ips
  tags               = local.tags
}

resource "aws_wafv2_web_acl" "main" {
  region = "us-east-1"
  name   = local.name
  scope  = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        dynamic "rule_action_override" {
          for_each = var.aws_common_excluded_rules
          content {
            name = rule_action_override.value
            action_to_use {
              count {}
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate-limit-per-ip"
    priority = 3

    action {
      block {
        custom_response {
          response_code = 429
        }
      }
    }

    statement {
      rate_based_statement {
        aggregate_key_type    = "IP"
        limit                 = var.rate_limit
        evaluation_window_sec = var.evaluation_window_sec

        dynamic "scope_down_statement" {
          for_each = aws_wafv2_ip_set.rate_limit_excluded
          content {
            not_statement {
              statement {
                ip_set_reference_statement {
                  arn = scope_down_statement.value.arn
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-per-ip"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.name
    sampled_requests_enabled   = true
  }

  tags = local.tags
}
