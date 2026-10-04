resource "aws_lb_target_group" "alb_tg" {
  name                          = local.name
  port                          = var.port
  protocol                      = var.protocol
  vpc_id                        = var.vpc_id
  target_type                   = var.target_type
  load_balancing_algorithm_type = "round_robin"
  slow_start                    = 0
  tags = {
    Name = "${var.environment}-${var.application}-tg"
  }
  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.health_check_protocol
    timeout             = 10
    unhealthy_threshold = 5
  }
  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "alb_tg_attach" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = var.resrouce_id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_certificate" "cert" {
  count           = var.alb_listener_cert_enabled ? 1 : 0
  listener_arn    = var.listener_arn
  certificate_arn = var.certificate_arn
}

resource "aws_lb_listener_rule" "rule" {
  listener_arn = var.listener_arn
  priority     = var.priority
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
  condition {
    host_header {
      values = [var.domain_name]
    }
  }
  depends_on = [aws_lb_target_group.alb_tg]
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.environment}-${var.application}-lr"
  }
}