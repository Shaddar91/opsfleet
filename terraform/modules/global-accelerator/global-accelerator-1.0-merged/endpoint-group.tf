resource "aws_globalaccelerator_endpoint_group" "main" {
  for_each = { for k, v in var.listeners : k => v if v.endpoint_group != null }

  listener_arn                  = aws_globalaccelerator_listener.main[each.key].id
  endpoint_group_region         = each.value.endpoint_group.region != null ? each.value.endpoint_group.region : data.aws_region.current.region
  health_check_protocol         = each.value.endpoint_group.health_check_protocol
  health_check_port             = each.value.endpoint_group.health_check_port
  health_check_path             = each.value.endpoint_group.health_check_path
  health_check_interval_seconds = each.value.endpoint_group.health_check_interval_seconds
  threshold_count               = each.value.endpoint_group.threshold_count
  traffic_dial_percentage       = each.value.endpoint_group.traffic_dial_percentage

  dynamic "endpoint_configuration" {
    for_each = each.value.endpoint_group.endpoints
    content {
      endpoint_id                    = endpoint_configuration.value.endpoint_id
      weight                         = endpoint_configuration.value.weight
      client_ip_preservation_enabled = endpoint_configuration.value.client_ip_preservation_enabled
    }
  }

  lifecycle {
    ignore_changes = [health_check_path]
  }
}
