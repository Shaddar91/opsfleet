variable "application" {
  description = "Name part of the frontend resources: the <environment>-<application> certificate and the <environment>-<application>-cf-web-acl WAF ACL"
  type        = string
}

variable "web_subdomain" {
  description = "Label under the public zone; <web_subdomain>.<zone domain> is the certificate name, the distribution alias and the A and AAAA records"
  type        = string
  default     = "www"
}

variable "web_bucket_name" {
  description = "Name of the private site bucket; export TF_VAR_web_bucket_name from the env file outside the repo"
  type        = string
}

variable "log_bucket_name" {
  description = "Name of the access-log bucket; export TF_VAR_log_bucket_name from the env file outside the repo"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.log_bucket_name))
    error_message = "log_bucket_name must be 3-63 lowercase letters, digits or hyphens: CloudFront logging v2 rejects dots in the bucket name."
  }
}

variable "force_destroy" {
  description = "Let destroy delete the site and log buckets while they still hold objects, so tfctl.sh unroll can remove them; a change takes effect only after an apply"
  type        = bool
  default     = true
}

variable "web_noncurrent_days" {
  description = "Days a replaced or deleted site object version is kept before it expires"
  type        = number
}

variable "web_newer_noncurrent_versions" {
  description = "Newest noncurrent versions per site object kept past web_noncurrent_days, for rollback"
  type        = number
}

variable "web_abort_multipart_days" {
  description = "Days before an incomplete multipart upload to the site bucket is aborted"
  type        = number
}

variable "log_expire_days" {
  description = "Days before access logs expire from the log bucket"
  type        = number
}

variable "waf_rate_limit" {
  description = "Requests one client IP may send per waf_rate_window_sec before the WAF answers 429"
  type        = number
}

variable "waf_rate_window_sec" {
  description = "Window of the WAF rate rule in seconds: 60, 120, 300 or 600"
  type        = number
}

variable "waf_log_retention_days" {
  description = "Days the WAF log group keeps its logs"
  type        = number
}
