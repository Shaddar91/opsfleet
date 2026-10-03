//host rule on the edge ALB HTTPS listener (listener_arn from the edge stack) forwarding fqdn to the target group

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
