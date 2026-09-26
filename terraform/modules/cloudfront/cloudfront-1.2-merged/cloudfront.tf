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
    dynamic "custom_header" {
      for_each = var.custom_header_name != null && var.custom_header_name != "" ? [1] : []
      content {
        name  = var.custom_header_name
        value = var.custom_header_value
      }
    }
  }

  dynamic "origin" {
    for_each = var.enable_api_origin ? [1] : []
    content {
      origin_id   = var.api_origin_id
      domain_name = var.api_origin_domain_name

      custom_origin_config {
        origin_protocol_policy = var.api_origin_protocol_policy
        http_port              = 80
        https_port             = 443
        origin_ssl_protocols   = var.api_origin_ssl_protocols
      }

      custom_header {
        name  = var.api_custom_header_name
        value = var.api_custom_header_value
      }
    }
  }

  web_acl_id          = var.web_acl_id
  enabled             = true
  default_root_object = var.default_root_object
  aliases             = var.aliases
  price_class         = var.price_class

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = "origin-website.${var.domain}"

    dynamic "lambda_function_association" {
      for_each = var.lambda_arn != null && var.lambda_arn != "" ? [1] : []
      content {
        event_type   = var.event_type
        lambda_arn   = var.lambda_arn
        include_body = var.include_body
      }
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

  dynamic "ordered_cache_behavior" {
    for_each = var.enable_api_origin ? [1] : []
    content {
      path_pattern     = var.api_path_pattern
      target_origin_id = var.api_origin_id
      allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods   = ["GET", "HEAD"]

      forwarded_values {
        query_string = true
        headers      = var.api_forwarded_headers
        cookies {
          forward = "none"
        }
      }

      viewer_protocol_policy = "https-only"
      min_ttl                = 0
      default_ttl            = 0
      max_ttl                = 0
      compress               = true

      dynamic "function_association" {
        for_each = var.api_function_arn != null ? [1] : []
        content {
          event_type   = var.api_function_event_type
          function_arn = var.api_function_arn
        }
      }
    }
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
