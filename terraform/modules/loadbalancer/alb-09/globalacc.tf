resource "aws_globalaccelerator_accelerator" "main" {
  count   = var.create_global_accelerator ? 1 : 0
  enabled = var.ga_enabled_on_aws_level
  name    = "${var.environment}-${var.application}-accelerator"

  tags = {
    Name = "${var.environment}-${var.application}-accelerator"
  }
}

resource "aws_globalaccelerator_listener" "main" {
  count           = var.create_global_accelerator ? 1 : 0
  accelerator_arn = aws_globalaccelerator_accelerator.main[0].id
  client_affinity = "NONE"
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }

  dynamic "port_range" {
    for_each = var.accept_http ? [1] : []
    content {
      from_port = 80
      to_port   = 80
    }
  }
}

resource "aws_globalaccelerator_endpoint_group" "main" {
  count                         = var.create_global_accelerator ? 1 : 0
  endpoint_group_region         = data.aws_region.current.id
  health_check_path             = var.health_check_path
  health_check_interval_seconds = 30
  health_check_port             = 443
  health_check_protocol         = "TCP"
  listener_arn                  = aws_globalaccelerator_listener.main[0].id
  threshold_count               = 3
  traffic_dial_percentage       = 100

  endpoint_configuration {
    client_ip_preservation_enabled = true
    endpoint_id                    = aws_lb.main.id
    weight                         = 100
  }

  lifecycle {
    ignore_changes = [health_check_path]
  }
}

resource "aws_route53_health_check" "main" {
  count             = var.create_global_accelerator ? 1 : 0
  failure_threshold = "3"
  fqdn              = aws_globalaccelerator_accelerator.main[0].dns_name
  port              = 443
  request_interval  = "10"
  type              = "TCP"

  tags = {
    Name = "${var.environment}-${var.application}"
  }
}
