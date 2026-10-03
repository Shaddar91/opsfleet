resource "aws_globalaccelerator_accelerator" "main" {
  name            = var.accelerator_name != null ? var.accelerator_name : "${local.name}-accelerator"
  enabled         = var.enabled
  ip_address_type = var.ip_address_type

  dynamic "attributes" {
    for_each = var.flow_logs != null ? [var.flow_logs] : []
    content {
      flow_logs_enabled   = true
      flow_logs_s3_bucket = attributes.value.s3_bucket
      flow_logs_s3_prefix = attributes.value.s3_prefix
    }
  }

  tags = merge(
    {
      Name        = "${local.name}-accelerator"
      Environment = var.environment
      Application = var.application
    },
    var.tags
  )
}
