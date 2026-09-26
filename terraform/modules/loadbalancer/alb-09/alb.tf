resource "aws_lb" "main" {
  name                       = "${var.environment}-${var.application}"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  security_groups            = [module.alb_sg.sg.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = true
  drop_invalid_header_fields = true
  idle_timeout               = 60
  internal                   = var.internal

  access_logs {
    bucket  = module.alb_log_bucket.s3.bucket
    prefix  = var.access_logs_prefix
    enabled = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    module.alb_log_bucket
  ]

  tags = {
    Name        = "${var.environment}-${var.application}"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  count             = var.accept_http ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  certificate_arn   = var.create_certificate ? module.cert[0].arn : var.certificate_arn
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden."
      status_code  = "403"
    }
  }
}
