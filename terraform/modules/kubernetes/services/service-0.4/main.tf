//ip target group on the edge ALB; pods are registered by the TargetGroupBinding (binding.tf) or the app chart

resource "aws_lb_target_group" "this" {
  name                 = local.target_group_name
  target_type          = "ip"
  port                 = var.container_port
  protocol             = "HTTP"
  protocol_version     = "HTTP1"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    path    = var.health_check_path
    port    = "traffic-port"
    matcher = var.health_check_matcher
  }

  lifecycle {
    create_before_destroy = true
  }
}
