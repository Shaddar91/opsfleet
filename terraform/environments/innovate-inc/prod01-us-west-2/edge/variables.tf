variable "application" {
  description = "Name part of the edge resources: the <environment>-<application> ALB, security group, WAF ACL and -ingress target group"
  type        = string
}

variable "waf_rate_limit" {
  description = "Requests one client IP may send in a 5-minute window before the WAF blocks it"
  type        = number
}

variable "enable_deletion_protection" {
  description = "Block ALB deletion; false lets tfctl.sh unroll remove it"
  type        = bool
}

variable "edge_log_bucket_name" {
  description = "Name of the access and WAF log bucket; export TF_VAR_edge_log_bucket_name from the env file outside the repo"
  type        = string
}

variable "log_expire_days" {
  description = "Days before access and WAF logs expire from the log bucket"
  type        = number
}

variable "log_bucket_force_destroy" {
  description = "Let destroy delete the log bucket while it still holds logs, so tfctl.sh unroll can remove it; a change takes effect only after an apply"
  type        = bool
}

variable "ingress_rule_priority" {
  description = "Priority of the HTTPS listener rule that forwards the app host to the ingress target group"
  type        = number
}

variable "global_accelerator_traffic_dial_percentage" {
  description = "Share of the accelerator's traffic this region takes, 0 to 100"
  type        = number
}
