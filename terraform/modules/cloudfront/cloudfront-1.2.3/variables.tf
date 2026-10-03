variable "environment" {
  type = string
}

variable "domain" {
  description = "domain name"
  type        = string
}

variable "s3_endpoint" {
  description = "end point from s3 bucket"
  type        = string
}

variable "origin_protocol_policy" {
  description = "(Required) - The origin protocol policy to apply to your origin. One of http-only, https-only, or match-viewer"
  type        = string
  default     = "http-only"
}

variable "http_port" {
  type    = string
  default = "80"
}

variable "https_port" {
  type    = string
  default = "443"
}

variable "origin_ssl_protocols" {
  description = "(Required) - The SSL/TLS protocols that you want CloudFront to use when communicating with your origin over HTTPS. A list of one or more of SSLv3, TLSv1, TLSv1.1, and TLSv1.2."
  type        = list(string)
  default     = ["TLSv1.2"]
}

variable "custom_header_name" {
  description = "custom_header (Optional) - One or more sub-resources with name and value parameters that specify header data that will be sent to the origin (multiples allowed). E.G User-Agent"
  type        = string
  default     = null
}

variable "custom_header_value" {
  description = "Value for custom header"
  type        = string
  default     = null
}

variable "web_acl_id" {
  description = "(Optional) - A unique identifier that specifies the AWS WAF web ACL, if any, to associate with this distribution.To specify a web ACL created using the latest version of AWS WAF (WAFv2), use the ACL ARN, for example aws_wafv2_web_acl.example.arn. To specify a web ACL created using AWS WAF Classic, use the ACL ID, for example aws_waf_web_acl.example.id. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned."
  type        = string
  default     = null
}

variable "default_root_object" {
  type        = string
  description = "default_root_object (Optional) - The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL"
}

variable "price_class" {
  description = "(Optional) - The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100 https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html"
  type        = string
  default     = "PriceClass_All"
}

variable "allowed_methods" {
  description = "allowed_methods (Required) - Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "cached_methods (Required) - Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "viewer_functions" {
  type        = map(string)
  default     = {}
  description = "CloudFront Functions (cloudfront-js-2.0) on the default behavior: viewer-request or viewer-response mapped to the function's JavaScript. Excludes a Lambda@Edge viewer event on the same behavior."

  validation {
    condition     = alltrue([for event in keys(var.viewer_functions) : contains(["viewer-request", "viewer-response"], event)])
    error_message = "viewer_functions keys must be viewer-request or viewer-response."
  }
}

variable "query_string" {
  description = "query_string (Required) - Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior."
  type        = bool
  default     = false
}

variable "forward" {
  description = "forward (Required) - Specifies whether you want CloudFront to forward cookies to the origin that is associated with this cache behavior. You can specify all, none or whitelist. If whitelist, you must include the subsequent whitelisted_names"
  type        = string
  default     = "none"
}

variable "viewer_protocol_policy" {
  description = "viewer_protocol_policy (Required) - Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. One of allow-all, https-only, or redirect-to-https."
  type        = string
  default     = "redirect-to-https"
}

variable "min_ttl" {
  description = "min_ttl (Optional) - The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated. Defaults to 0 seconds."
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "default_ttl (Optional) - The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header"
  type        = number
  default     = 300
}

variable "max_ttl" {
  description = "max_ttl (Optional) - The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Only effective in the presence of Cache-Control max-age, Cache-Control s-maxage, and Expires headers"
  type        = number
  default     = 1200
}

variable "compress" {
  description = "compress (Optional) - Whether you want CloudFront to automatically compress content for web requests that include Accept-Encoding: gzip in the request header (default: false)."
  type        = bool
  default     = true
}

variable "custom_error_responses" {
  description = "Custom error responses, one per HTTP error code. An SPA maps 403 and 404 to /index.html with response_code 200 and error_caching_min_ttl 0."
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

variable "restriction_type" {
  description = "restriction_type (Required) - The method that you want to use to restrict distribution of your content by country: none, whitelist, or blacklist."
  type        = string
  default     = "none"
}

variable "acm_certificate_arn" {
  description = "acm_certificate_arn - The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution. Specify this, cloudfront_default_certificate, or iam_certificate_id. The ACM certificate must be in US-EAST-1."
  type        = string
}

variable "minimum_protocol_version" {
  description = "minimum_protocol_version - The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. Can only be set if cloudfront_default_certificate = false. See all possible values in this table under 'Security policy.' Some examples include: TLSv1.2_2019 and TLSv1.2_2021. Default: TLSv1. NOTE: If you are using a custom certificate (specified with acm_certificate_arn or iam_certificate_id), and have specified sni-only in ssl_support_method, TLSv1 or later must be specified. If you have specified vip in ssl_support_method, only SSLv3 or TLSv1 can be specified. If you have specified cloudfront_default_certificate, TLSv1 must be specified."
  type        = string
  default     = "TLSv1.2_2019"
}

variable "ssl_support_method" {
  description = "ssl_support_method: Specifies how you want CloudFront to serve HTTPS requests. One of vip or sni-only. Required if you specify acm_certificate_arn or iam_certificate_id. NOTE: vip causes CloudFront to use a dedicated IP address and may incur extra charges."
  type        = string
  default     = "sni-only"
}

variable "aliases" {
  type = list(string)
}

variable "enable_api_origin" {
  type        = bool
  default     = false
  description = "Enable a secondary `api` origin + `/api/*` ordered cache behavior."
}

variable "api_origin_domain_name" {
  type        = string
  default     = null
  description = "Public hostname of the api origin. Required when enable_api_origin = true."
}

variable "api_origin_id" {
  type        = string
  default     = "api-origin"
  description = "CloudFront origin_id for the api origin."
}

variable "api_path_pattern" {
  type    = string
  default = "/api/*"
}

variable "api_custom_header_name" {
  type    = string
  default = "X-Origin-Verify"
}

variable "api_custom_header_value" {
  type        = string
  default     = null
  sensitive   = true
  description = "Shared secret CloudFront sends to the api origin in api_custom_header_name, so the origin can reject requests that bypass CloudFront."
}

variable "api_origin_protocol_policy" {
  type    = string
  default = "https-only"
}

variable "api_origin_ssl_protocols" {
  type    = list(string)
  default = ["TLSv1.2"]
}

variable "api_forwarded_headers" {
  type        = list(string)
  default     = ["Origin", "Content-Type"]
  description = "Request headers the api behavior forwards to the api origin."
}

variable "api_function_arn" {
  type        = string
  default     = null
  description = "Optional aws_cloudfront_function ARN associated to the /api/* behavior on viewer-request (used for prefix stripping)."
}

variable "api_function_event_type" {
  type    = string
  default = "viewer-request"
}

variable "origin_type" {
  type        = string
  default     = "custom"
  description = "custom: a website or HTTP origin through custom_origin_config. s3-oac: a private S3 bucket's regional domain name through an origin access control."

  validation {
    condition     = contains(["custom", "s3-oac"], var.origin_type)
    error_message = "origin_type must be custom or s3-oac."
  }
}

variable "is_ipv6_enabled" {
  type        = bool
  default     = false
  description = "Serve the distribution over IPv6. An AAAA alias record needs it."
}

variable "cache_policy_id" {
  type        = string
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  description = "Cache policy of the default behavior; the default is the AWS managed CachingOptimized policy. Null falls back to forwarded_values and the ttl inputs."
}

variable "security_headers" {
  type = object({
    hsts_max_age_sec        = optional(number)
    hsts_include_subdomains = optional(bool, false)
    hsts_preload            = optional(bool, false)
    content_type_options    = optional(bool, false)
    frame_option            = optional(string)
    referrer_policy         = optional(string)
    xss_protection          = optional(bool)
    content_security_policy = optional(string)
    override                = optional(bool, true)
  })
  default     = null
  description = "Builds a response headers policy for the default behavior. A null or false field omits that header; override lets each header replace the origin's. Set this or response_headers_policy_id."

  validation {
    condition     = try(var.security_headers.frame_option == null || contains(["DENY", "SAMEORIGIN"], var.security_headers.frame_option), true)
    error_message = "security_headers.frame_option must be DENY or SAMEORIGIN."
  }

  validation {
    condition     = try(var.security_headers.referrer_policy == null || contains(["no-referrer", "no-referrer-when-downgrade", "origin", "origin-when-cross-origin", "same-origin", "strict-origin", "strict-origin-when-cross-origin", "unsafe-url"], var.security_headers.referrer_policy), true)
    error_message = "security_headers.referrer_policy must be a CloudFront referrer policy value."
  }
}

variable "response_headers_policy_id" {
  type        = string
  default     = null
  description = "Existing response headers policy for the default behavior, such as a managed one. Set this or security_headers."
}

variable "enable_logging" {
  type        = bool
  default     = false
  description = "Standard logging v2: deliver access logs to log_bucket_arn through CloudWatch log delivery in us-east-1."
}

variable "log_bucket_arn" {
  type        = string
  default     = null
  description = "ARN of the S3 bucket receiving access logs when enable_logging is true. Its bucket policy must allow delivery.logs.amazonaws.com to write."
}

variable "log_output_format" {
  type        = string
  default     = "json"
  description = "Access log format in S3: json, plain, w3c, raw or parquet."

  validation {
    condition     = contains(["json", "plain", "w3c", "raw", "parquet"], var.log_output_format)
    error_message = "log_output_format must be json, plain, w3c, raw or parquet."
  }
}

variable "lambda_associations" {
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = optional(bool, false)
  }))
  default     = []
  description = "Lambda@Edge functions on the default behavior, one entry per event type (viewer-request, viewer-response, origin-request, origin-response); lambda_arn is the published, qualified ARN. The same function may serve several event types."

  validation {
    condition     = alltrue([for a in var.lambda_associations : contains(["viewer-request", "viewer-response", "origin-request", "origin-response"], a.event_type)])
    error_message = "event_type must be viewer-request, viewer-response, origin-request or origin-response."
  }

  validation {
    condition     = length(distinct([for a in var.lambda_associations : a.event_type])) == length(var.lambda_associations)
    error_message = "One Lambda@Edge function per event type."
  }
}
