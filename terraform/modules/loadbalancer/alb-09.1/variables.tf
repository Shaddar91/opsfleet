variable "application" {
  type        = string
  description = "Application name for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, stage, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB will be deployed"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC; the default security group rules send all ALB egress here"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ALB"
}

variable "create_global_accelerator" {
  type        = bool
  default     = false
  description = "Create Global Accelerator in this module. When true, GA is created and Route53 points to it."
}

variable "ga_enabled_on_aws_level" {
  type        = bool
  default     = true
  description = "Whether the Global Accelerator is enabled at AWS level. Only applies when create_global_accelerator=true."
}

variable "use_external_global_accelerator" {
  type        = bool
  default     = false
  description = "Point Route53 to an external Global Accelerator (created in separate module). Mutually exclusive with create_global_accelerator."
}

variable "external_global_accelerator_dns_name" {
  type        = string
  default     = null
  description = "DNS name of external Global Accelerator. Required when use_external_global_accelerator=true."
}

variable "external_global_accelerator_zone_id" {
  type        = string
  default     = null
  description = "Hosted zone ID of external Global Accelerator. Required when use_external_global_accelerator=true."
}

variable "create_route53_record" {
  type        = bool
  default     = true
  description = "Create Route53 record in this module. Set to false if DNS is managed elsewhere."
}

variable "enable_waf" {
  type        = bool
  default     = false
  description = "Enable AWS WAF for the ALB. When true, creates WAF Web ACL and associates it with the ALB."
}

variable "enable_waf_whitelist" {
  type        = bool
  default     = false
  description = "Create WAF whitelist IP set. When true, whitelisted IPs bypass all WAF rules."
}

variable "waf_whitelist_name" {
  type        = string
  default     = null
  description = "Name of WAF Whitelist IP set. Defaults to {environment}-{application}-lb-whitelist"
}

variable "waf_blacklist_name" {
  type        = string
  default     = null
  description = "Name of WAF Blacklist IP set. Defaults to {environment}-{application}-lb-blacklist"
}

variable "waf_acl_name" {
  type        = string
  default     = null
  description = "Name of WAF Web ACL. Defaults to {environment}-{application}-lb-web-acl"
}

variable "rate_limit_excluded_ips" {
  type        = list(string)
  default     = []
  description = "List of IPs to exclude from rate limit rule"
}

variable "rate_limit" {
  type    = number
  default = 2000
}

variable "waf_whitelisted_ips" {
  type    = list(any)
  default = []
}

variable "waf_blacklisted_ips" {
  type    = list(any)
  default = []
}

variable "aws_common_excluded_rules" {
  type        = list(string)
  default     = []
  description = "List of rule names to exclude (set to COUNT) from AWSManagedRulesCommonRuleSet. Example: [\"SizeRestrictions_BODY\", \"CrossSiteScripting_BODY\"]"
}

variable "waf_allowed_paths" {
  type        = list(string)
  default     = []
  description = "List of URI path prefixes to allow through WAF without inspection. Uses STARTS_WITH matching (e.g., [\"/saml/\"] matches /saml/tenant, etc.)"
}

variable "internal" {
  type        = bool
  default     = false
  description = "Whether the ALB is internal (private) or internet-facing (public). true = private ALB, false = public ALB."
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}

variable "accept_http" {
  type        = bool
  default     = true
  description = "Whether to accept HTTP traffic (will redirect to HTTPS)"
}

variable "rules_cidr" {
  type        = list(any)
  default     = null
  description = "Security group rules for the ALB. Null opens TCP 443 (and 80 when accept_http) from 0.0.0.0/0 and sends egress to vpc_cidr only"
}

variable "create_certificate" {
  type        = bool
  default     = true
  description = "Whether to create a new ACM certificate for the ALB"
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "ARN of existing certificate to use (only used when create_certificate=false)"
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "access_logs_prefix" {
  type    = string
  default = "logs"
}

variable "bucket_versioning" {
  type    = string
  default = "Enabled"
}

variable "object_ownership" {
  type    = string
  default = "BucketOwnerEnforced"
}

variable "block_public_policy" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
}

variable "block_public_acls" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should block public ACLs for this bucket."
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
}

variable "log_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "Let destroy delete the log bucket while it still holds logs. A change takes effect only after an apply has stored it"
}

variable "expire_days" {
  type        = number
  description = "Number of days before logs expire in S3"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for DNS records"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the ALB (used for certificate and DNS)"
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "Health check path for Global Accelerator and ALB"
}
