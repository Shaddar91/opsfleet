resource "aws_cloudfront_distribution" "main" {
  origin {
    origin_id   = "origin-website.${var.domain}"
    domain_name = var.s3_endpoint

    custom_origin_config {
      origin_protocol_policy = var.origin_protocol_policy
      http_port              = var.http_port
      https_port             = var.https_port
      origin_ssl_protocols   = var.origin_ssl_protocols
    }
    custom_header {
      name  = var.custom_header_name
      value = var.custom_header_value
    }
  }

  enabled             = true
  default_root_object = var.default_root_object
  aliases             = var.aliases
  price_class         = var.price_class

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = "origin-website.${var.domain}"

    lambda_function_association {
      event_type   = var.event_type
      lambda_arn   = var.lambda_arn
      include_body = var.include_body
    }
    forwarded_values {
      query_string = var.query_string

      cookies {
        forward = var.forward
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    compress               = var.compress
  }

  custom_error_response {
    error_code         = var.error_code
    response_code      = var.response_code
    response_page_path = var.response_page_path
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = var.minimum_protocol_version
    ssl_support_method       = var.ssl_support_method
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
