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

variable "event_type" {
  description = "event_type (Required) - The specific event to trigger this function. Valid values: viewer-request or viewer-response. Used only with lambdas"
  type        = string
  default     = null
}

variable "lambda_arn" {
  description = "function_arn (Required) - ARN of the Cloudfront function."
  type        = string
  default     = null
}

variable "include_body" {
  description = "include_body (Optional) - When set to true it exposes the request body to the lambda function. Defaults to false. Valid values: true, false."
  type        = bool
  default     = null
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

variable "error_code" {
  description = "error_code (Required) - The 4xx or 5xx HTTP status code that you want to customize."
  type        = number
  default     = 404
}

variable "response_code" {
  description = "response_code (Optional) - The HTTP status code that you want CloudFront to return with the custom error page to the viewer."
  type        = number
  default     = 200
}

variable "response_page_path" {
  description = "response_page_path (Optional) - The path of the custom error page (for example, /custom_404.html)."
  type        = string
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
