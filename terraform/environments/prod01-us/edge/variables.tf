variable "application" {
  description = "Name part of every edge resource: <environment>-<application> ALB, -alb-logs bucket, -ingress target group"
  type        = string
  default     = "edge"
}

variable "app_subdomain" {
  description = "Label under the public zone; <app_subdomain>.<zone domain> is the certificate name, the host rule and the Global Accelerator record"
  type        = string
  default     = "app"
}

variable "waf_rate_limit" {
  description = "Requests one client IP may send in a 5-minute window before the WAF blocks it"
  type        = number
  default     = 2000
}

variable "enable_deletion_protection" {
  description = "Block ALB deletion; false lets tfctl.sh unroll remove it"
  type        = bool
  default     = false
}

variable "log_expire_days" {
  description = "Days before access and WAF logs expire from the log bucket"
  type        = number
  default     = 180
}

variable "log_bucket_force_destroy" {
  description = "Let destroy delete the log bucket while it still holds logs, so tfctl.sh unroll can remove it; a change takes effect only after an apply"
  type        = bool
  default     = true
}

variable "ingress_rule_priority" {
  description = "Priority of the HTTPS listener rule that forwards the app host to the ingress target group"
  type        = number
  default     = 100
}
