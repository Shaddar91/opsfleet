#----------------------------------------------------------
#WAF Resources
#Only created when enable_waf = true
#----------------------------------------------------------

resource "aws_wafv2_web_acl_association" "main" {
  count        = var.enable_waf ? 1 : 0
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main[0].arn
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count                   = var.enable_waf ? 1 : 0
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.main[0].arn]
  resource_arn            = aws_wafv2_web_acl.main[0].arn

  redacted_fields {
    single_header {
      name = "user-agent"
    }
  }
}


resource "aws_wafv2_ip_set" "whitelist" {
  count              = var.enable_waf && var.enable_waf_whitelist ? 1 : 0
  name               = var.waf_whitelist_name == null ? "${var.environment}-${var.application}-lb-whitelist" : var.waf_whitelist_name
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.waf_whitelisted_ips

  tags = {
    Name = var.waf_whitelist_name == null ? "${var.environment}-${var.application}-lb-whitelist" : var.waf_whitelist_name
  }
}

resource "aws_wafv2_ip_set" "blacklist" {
  count              = var.enable_waf ? 1 : 0
  name               = var.waf_blacklist_name == null ? "${var.environment}-${var.application}-lb-blacklist" : var.waf_blacklist_name
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.waf_blacklisted_ips

  tags = {
    Name = var.waf_blacklist_name == null ? "${var.environment}-${var.application}-lb-blacklist" : var.waf_blacklist_name
  }
}

resource "aws_wafv2_ip_set" "rate_limit_excluded_ipset" {
  count              = var.enable_waf && length(var.rate_limit_excluded_ips) > 0 ? 1 : 0
  name               = "${var.environment}-${var.application}-rate-limit-excluded-ipset"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.rate_limit_excluded_ips

  tags = {
    Name = "${var.environment}-${var.application}-rate-limit-excluded-ipset"
  }
}

resource "aws_wafv2_web_acl" "main" {
  count = var.enable_waf ? 1 : 0
  name  = var.waf_acl_name == null ? "${var.environment}-${var.application}-lb-web-acl" : var.waf_acl_name
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  #----------------------------------------------------------
  #Priority 1: Whitelist - ALLOW these IPs (bypass all other rules)
  #Only created when enable_waf_whitelist = true AND waf_whitelisted_ips is not empty
  #----------------------------------------------------------
  dynamic "rule" {
    for_each = var.enable_waf_whitelist && length(var.waf_whitelisted_ips) > 0 ? [1] : []
    content {
      name     = "whitelisted-ips"
      priority = 1

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.whitelist[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "whitelisted-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  #----------------------------------------------------------
  #Priority 0: Path-based ALLOW - bypass all WAF rules for these paths
  #Single path uses byte_match directly, multiple paths use or_statement
  #----------------------------------------------------------
  dynamic "rule" {
    for_each = length(var.waf_allowed_paths) == 1 ? [1] : []
    content {
      name     = "allowed-paths"
      priority = 0

      action {
        allow {}
      }

      statement {
        byte_match_statement {
          positional_constraint = "STARTS_WITH"
          search_string         = var.waf_allowed_paths[0]
          field_to_match {
            uri_path {}
          }
          text_transformation {
            priority = 0
            type     = "URL_DECODE"
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "allowed-paths"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = length(var.waf_allowed_paths) > 1 ? [1] : []
    content {
      name     = "allowed-paths"
      priority = 0

      action {
        allow {}
      }

      statement {
        or_statement {
          dynamic "statement" {
            for_each = var.waf_allowed_paths
            content {
              byte_match_statement {
                positional_constraint = "STARTS_WITH"
                search_string         = statement.value
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "URL_DECODE"
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "allowed-paths"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 2

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
    priority = 3

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
    name     = "blacklisted-ips"
    priority = 4

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blacklist[0].arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blacklisted-ips"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 6

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
    priority = 7

    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = var.rate_limit

        dynamic "scope_down_statement" {
          for_each = aws_wafv2_ip_set.rate_limit_excluded_ipset
          content {
            not_statement {
              statement {
                ip_set_reference_statement {
                  arn = aws_wafv2_ip_set.rate_limit_excluded_ipset[0].arn
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
    metric_name                = "main-waf"
    sampled_requests_enabled   = true
  }
}
