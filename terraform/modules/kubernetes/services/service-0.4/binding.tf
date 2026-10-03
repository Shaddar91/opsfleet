//TargetGroupBinding for a Service Terraform deploys (a platform component); an Argo CD app ships its own binding in the chart.

resource "kubectl_manifest" "target_group_binding" {
  count = var.create_target_group_binding ? 1 : 0

  yaml_body = templatefile(local.target_group_binding_template, {
    NAME             = var.service_name
    NAMESPACE        = var.namespace
    TARGET_GROUP_ARN = aws_lb_target_group.this.arn
    SERVICE_NAME     = var.service_name
    SERVICE_PORT     = var.service_port
  })
  force_new = true
  wait      = true

  lifecycle {
    precondition {
      condition     = var.service_name != null && var.service_port != null
      error_message = "create_target_group_binding needs service_name and service_port."
    }
    precondition {
      condition     = !var.custom_target_group_binding || var.target_group_binding_path != null
      error_message = "custom_target_group_binding needs target_group_binding_path."
    }
  }
}
