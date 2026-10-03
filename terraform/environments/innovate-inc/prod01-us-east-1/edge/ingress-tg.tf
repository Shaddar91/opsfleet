#Cluster ingress: an ip target group on Traefik's web port, filled in-cluster by a TargetGroupBinding, and the app host rule.

resource "aws_lb_target_group" "ingress" {
  name                 = "${var.environment}-${var.application}-ingress"
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
    Name        = "${var.environment}-${var.application}-ingress"
    Environment = var.environment
  }
}

resource "aws_lb_listener_rule" "ingress" {
  listener_arn = module.alb.https_listener_arn
  priority     = var.ingress_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress.arn
  }

  condition {
    host_header {
      values = [local.app_fqdn]
    }
  }
}
