locals {
  origin_id                  = "origin-website.${var.domain}"
  name                       = replace("${var.environment}-${var.domain}", ".", "-")
  response_headers_policy_id = var.security_headers != null ? one(aws_cloudfront_response_headers_policy.main[*].id) : var.response_headers_policy_id

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_cloudfront_origin_access_control" "main" {
  count                             = var.origin_type == "s3-oac" ? 1 : 0
  name                              = substr(local.name, 0, 64)
  description                       = "S3 origin access for ${var.domain}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "main" {
  count   = var.security_headers != null ? 1 : 0
  name    = substr("${local.name}-security-headers", 0, 128)
  comment = "Security headers for ${var.domain}"

  security_headers_config {
    dynamic "strict_transport_security" {
      for_each = var.security_headers.hsts_max_age_sec != null ? [1] : []
      content {
        access_control_max_age_sec = var.security_headers.hsts_max_age_sec
        include_subdomains         = var.security_headers.hsts_include_subdomains
        preload                    = var.security_headers.hsts_preload
        override                   = var.security_headers.override
      }
    }

    dynamic "content_type_options" {
      for_each = var.security_headers.content_type_options ? [1] : []
      content {
        override = var.security_headers.override
      }
    }

    dynamic "frame_options" {
      for_each = var.security_headers.frame_option != null ? [1] : []
      content {
        frame_option = var.security_headers.frame_option
        override     = var.security_headers.override
      }
    }

    dynamic "referrer_policy" {
      for_each = var.security_headers.referrer_policy != null ? [1] : []
      content {
        referrer_policy = var.security_headers.referrer_policy
        override        = var.security_headers.override
      }
    }

    dynamic "xss_protection" {
      for_each = var.security_headers.xss_protection != null ? [1] : []
      content {
        protection = var.security_headers.xss_protection
        mode_block = var.security_headers.xss_protection
        override   = var.security_headers.override
      }
    }

    dynamic "content_security_policy" {
      for_each = var.security_headers.content_security_policy != null ? [1] : []
      content {
        content_security_policy = var.security_headers.content_security_policy
        override                = var.security_headers.override
      }
    }
  }
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    origin_id                = local.origin_id
    domain_name              = var.s3_endpoint
    origin_access_control_id = one(aws_cloudfront_origin_access_control.main[*].id)

    dynamic "custom_origin_config" {
      for_each = var.origin_type == "custom" ? [1] : []
      content {
        origin_protocol_policy = var.origin_protocol_policy
        http_port              = var.http_port
        https_port             = var.https_port
        origin_ssl_protocols   = var.origin_ssl_protocols
      }
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
  is_ipv6_enabled     = var.is_ipv6_enabled
  default_root_object = var.default_root_object
  aliases             = var.aliases
  price_class         = var.price_class

  default_cache_behavior {
    allowed_methods            = var.allowed_methods
    cached_methods             = var.cached_methods
    target_origin_id           = local.origin_id
    cache_policy_id            = var.cache_policy_id
    response_headers_policy_id = local.response_headers_policy_id

    dynamic "lambda_function_association" {
      for_each = var.lambda_arn != null && var.lambda_arn != "" ? [1] : []
      content {
        event_type   = var.event_type
        lambda_arn   = var.lambda_arn
        include_body = var.include_body
      }
    }
    dynamic "forwarded_values" {
      for_each = var.cache_policy_id == null ? [1] : []
      content {
        query_string = var.query_string

        cookies {
          forward = var.forward
        }
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.cache_policy_id == null ? var.min_ttl : null
    default_ttl            = var.cache_policy_id == null ? var.default_ttl : null
    max_ttl                = var.cache_policy_id == null ? var.max_ttl : null
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

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
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

  tags = local.tags

  lifecycle {
    precondition {
      condition     = var.security_headers == null || var.response_headers_policy_id == null
      error_message = "Set security_headers or response_headers_policy_id, not both."
    }
    precondition {
      condition     = !var.enable_logging || var.log_bucket_arn != null
      error_message = "enable_logging needs log_bucket_arn."
    }
  }
}
