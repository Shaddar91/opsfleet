resource "aws_codedeploy_app" "main" {
  compute_platform = var.compute_platform
  name             = "${var.environment}-${var.application}-codedeploy"
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  autoscaling_groups     = var.asg_name != null && var.enable_asg_integration ? [var.asg_name] : []
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_group_name  = "${var.environment}-${var.application}-deploy-group"
  service_role_arn       = var.service_role
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      value = var.tag_value
      type  = "KEY_AND_VALUE"
    }
  }
}

resource "aws_autoscaling_lifecycle_hook" "codedeploy" {
  count                  = var.asg_name != null && var.enable_asg_integration && var.lifecycle_hook_enabled ? 1 : 0
  name                   = "CodeDeploy-deployment-hook"
  autoscaling_group_name = var.asg_name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  heartbeat_timeout      = var.lifecycle_hook_timeout
  default_result         = var.lifecycle_hook_default_result

  notification_metadata = jsonencode({
    DeploymentGroupName = aws_codedeploy_deployment_group.main.deployment_group_name
  })
}

resource "null_resource" "codedeploy_managed_hook" {
  count = var.asg_name != null && var.enable_asg_integration && !var.lifecycle_hook_enabled ? 1 : 0

  triggers = {
    deployment_group = aws_codedeploy_deployment_group.main.id
    asg_name         = var.asg_name
  }

  provisioner "local-exec" {
    command = "aws deploy update-deployment-group --application-name ${aws_codedeploy_app.main.name} --current-deployment-group-name ${aws_codedeploy_deployment_group.main.deployment_group_name} --auto-scaling-groups ${var.asg_name} --region ${data.aws_region.current.name}"
  }

  depends_on = [aws_codedeploy_deployment_group.main]
}
