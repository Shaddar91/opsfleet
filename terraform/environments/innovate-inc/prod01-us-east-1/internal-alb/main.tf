#prod01-us internal ALB on the private subnets: HTTP listener with a 404 default and an ip target group for in-cluster ingress.

resource "aws_lb" "internal" {
  name                       = "${var.environment}-internal-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = local.private_subnets
  drop_invalid_header_fields = true
  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name        = "${var.environment}-internal-alb"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = file("${path.module}/files/responses/not-found.json")
      status_code  = "404"
    }
  }

  tags = {
    Name        = "${var.environment}-internal-alb-http"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "internal_ingress" {
  name                 = "${var.environment}-internal-ingress"
  target_type          = "ip"
  port                 = 8000
  protocol             = "HTTP"
  protocol_version     = "HTTP1"
  vpc_id               = local.vpc_id
  deregistration_delay = 30

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "8080"
    path                = "/ping"
    matcher             = "200"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.environment}-internal-ingress"
    Environment = var.environment
  }
}

resource "aws_lb_listener_rule" "internal_ingress" {
  listener_arn = aws_lb_listener.http.arn
  priority     = var.ingress_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_ingress.arn
  }

  condition {
    host_header {
      values = local.internal_ingress_hosts
    }
  }

  tags = {
    Name        = "${var.environment}-internal-ingress"
    Environment = var.environment
  }
}
