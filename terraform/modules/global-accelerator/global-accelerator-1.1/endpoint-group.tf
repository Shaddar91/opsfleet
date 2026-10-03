resource "aws_globalaccelerator_endpoint_group" "main" {
  for_each = local.endpoint_groups

  listener_arn                  = aws_globalaccelerator_listener.main[each.value.listener].id
  endpoint_group_region         = each.value.region
  health_check_protocol         = each.value.health_check_protocol
  health_check_port             = each.value.health_check_port
  health_check_path             = each.value.health_check_path
  health_check_interval_seconds = each.value.health_check_interval_seconds
  threshold_count               = each.value.threshold_count
  traffic_dial_percentage       = each.value.traffic_dial_percentage

  dynamic "endpoint_configuration" {
    for_each = each.value.endpoints
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
