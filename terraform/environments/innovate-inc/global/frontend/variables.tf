variable "application" {
  description = "Name part of the frontend resources: the <environment>-<application> certificate and the <environment>-<application>-cf-web-acl WAF ACL"
  type        = string
}

variable "web_subdomain" {
  description = "Label under the public zone; <web_subdomain>.<zone domain> serves the site and is where the zone apex redirects"
  type        = string
}

variable "api_subdomain" {
  description = "Label under the public zone the API is served on; https://<api_subdomain>.<zone domain> is built in as VITE_API_BASE_URL"
  type        = string
}

variable "load_subdomain" {
  description = "Label under the public zone that app-services/of-load serves; https://<load_subdomain>.<zone domain> is the stress API the frontend calls, built in as VITE_LOAD_API_BASE_URL"
  type        = string
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

variable "enable_access_logs" {
  description = "true creates the access-log bucket and turns on the distribution's standard logging v2 into it; false creates neither"
  type        = bool
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

variable "web_build_values" {
  description = "of-web's build-time values, each set as a GitHub Actions secret of the repo and passed to npm run build; names are VITE_*. VITE_API_BASE_URL and VITE_LOAD_API_BASE_URL are not among them: they derive from api_subdomain and load_subdomain"
  type        = map(string)
  sensitive   = true

  validation {
    condition     = alltrue([for k in nonsensitive(keys(var.web_build_values)) : can(regex("^VITE_[A-Za-z0-9_]+$", k)) && k != "VITE_API_BASE_URL" && k != "VITE_LOAD_API_BASE_URL"])
    error_message = "web_build_values names must be VITE_* (Vite exposes no other name to the build) and must not be VITE_API_BASE_URL or VITE_LOAD_API_BASE_URL."
  }
}

variable "origin_secret" {
  description = "Secret CloudFront presents to the site bucket as the User-Agent; the bucket serves nothing without it. Lives only in the git-ignored secrets.auto.tfvars"
  type        = string
  sensitive   = true
}

variable "snyk_token" {
  description = "Snyk token the of-web snyk job runs with, set as its SNYK_TOKEN Actions secret; replace it before it expires. Lives only in the git-ignored secrets.auto.tfvars"
  type        = string
  sensitive   = true

  validation {
    condition     = nonsensitive(var.snyk_token != "")
    error_message = "snyk_token is empty: set it in the git-ignored secrets.auto.tfvars."
  }
}

variable "web_repository" {
  description = "of-web's repository name, without the owner: this stack sets its Actions secrets and commits its .github/workflows/ci.yml"
  type        = string
}

variable "artifact_prefix" {
  description = "Key prefix of the of-web builds in the artifact bucket, no trailing slash"
  type        = string
}
