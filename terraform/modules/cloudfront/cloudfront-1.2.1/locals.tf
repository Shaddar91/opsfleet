locals {
  origin_id                  = "origin-website.${var.domain}"
  name                       = replace("${var.environment}-${var.domain}", ".", "-")
  response_headers_policy_id = var.security_headers != null ? one(aws_cloudfront_response_headers_policy.main[*].id) : var.response_headers_policy_id

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
