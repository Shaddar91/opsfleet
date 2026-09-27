variable "environment" {
  type        = string
  description = "Environment name, used in the default web ACL name and in tags."
}

variable "application" {
  type        = string
  description = "Application name, used in the default web ACL name."
}

variable "name" {
  type        = string
  default     = null
  description = "Web ACL name. Defaults to {environment}-{application}-cf-web-acl. The log group is aws-waf-logs-{name}."

  validation {
    condition     = var.name == null || can(regex("^[A-Za-z0-9_-]{1,100}$", var.name))
    error_message = "name must be 1-100 characters of letters, digits, hyphens and underscores."
  }
}

variable "aws_common_excluded_rules" {
  type        = list(string)
  default     = []
  description = "AWSManagedRulesCommonRuleSet rule names switched to COUNT, e.g. [\"SizeRestrictions_BODY\"]."
}

variable "rate_limit" {
  type        = number
  default     = 2000
  description = "Requests per IP allowed within evaluation_window_sec before the rate rule answers 429."

  validation {
    condition     = var.rate_limit >= 10 && var.rate_limit <= 2000000000
    error_message = "rate_limit must be between 10 and 2000000000."
  }
}

variable "evaluation_window_sec" {
  type        = number
  default     = 300
  description = "Window the rate rule counts requests over: 60, 120, 300 or 600 seconds."

  validation {
    condition     = contains([60, 120, 300, 600], var.evaluation_window_sec)
    error_message = "evaluation_window_sec must be 60, 120, 300 or 600."
  }
}

variable "rate_limit_excluded_ips" {
  type        = list(string)
  default     = []
  description = "IPv4 CIDRs the rate rule never counts."
}

variable "redacted_headers" {
  type        = list(string)
  default     = ["authorization", "cookie"]
  description = "Request headers whose values WAF logs redact, in lowercase."

  validation {
    condition     = alltrue([for h in var.redacted_headers : h == lower(h)])
    error_message = "redacted_headers entries must be lowercase."
  }
}

variable "log_retention_days" {
  type        = number
  default     = 60
  description = "Retention of the WAF log group in days."
}
