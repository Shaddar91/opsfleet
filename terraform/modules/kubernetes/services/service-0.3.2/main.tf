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

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.fqdn]
    }
  }

  dynamic "condition" {
    for_each = [for c in var.extra_conditions : c if c.type == "http_header"]
    content {
      http_header {
        http_header_name = condition.value.name
        values           = condition.value.values
      }
    }
  }
  dynamic "condition" {
    for_each = [for c in var.extra_conditions : c if c.type == "path_pattern"]
    content {
      path_pattern {
        values = condition.value.values
      }
    }
  }
  dynamic "condition" {
    for_each = [for c in var.extra_conditions : c if c.type == "query_string"]
    content {
      query_string {
        key   = condition.value.name
        value = condition.value.values[0]
      }
    }
  }
  dynamic "condition" {
    for_each = [for c in var.extra_conditions : c if c.type == "http_request_method"]
    content {
      http_request_method {
        values = condition.value.values
      }
    }
  }
  dynamic "condition" {
    for_each = [for c in var.extra_conditions : c if c.type == "source_ip"]
    content {
      source_ip {
        values = condition.value.values
      }
    }
  }
}

module "certificate" {
  source = "../../../aws-pub-cert/certificate-1.0"

  enabled         = var.create_certificate
  route53_zone_id = var.zone_id
  domain_name     = var.fqdn
  environment     = var.environment
  application     = var.application
}

resource "aws_lb_listener_certificate" "this" {
  count = var.create_certificate ? 1 : 0

  listener_arn    = var.listener_arn
  certificate_arn = module.certificate.validated_arn
}

module "record" {
  source                  = "../../../r53/r53-1.2-merged"
  alias                   = true
  health_check            = true
  skip_empty_alias_target = false

  count = var.create_record ? 1 : 0

  zone_id            = var.zone_id
  domain_name        = var.fqdn
  type_of_dns_record = "A"
  resource_alias     = var.alias_target_dns_name
  resource_zone      = var.alias_target_zone_id
}

resource "aws_vpc_security_group_ingress_rule" "alb_to_pods" {
  count = var.create_security_group_rule ? 1 : 0

  security_group_id            = var.pod_security_group_id
  referenced_security_group_id = var.alb_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port
}
