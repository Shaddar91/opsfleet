output "lb_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller role, bound to kube-system/aws-load-balancer-controller by Pod Identity"
  value       = module.lbc_role.role_arn
}

output "release_name" {
  description = "Helm release name of the AWS Load Balancer Controller"
  value       = helm_release.aws_load_balancer_controller.name
}

output "namespace" {
  description = "Namespace the AWS Load Balancer Controller runs in"
  value       = helm_release.aws_load_balancer_controller.namespace
}

output "chart_version" {
  description = "Installed aws-load-balancer-controller chart version"
  value       = helm_release.aws_load_balancer_controller.version
}

output "status" {
  description = "Helm release status; deployed once the release is healthy"
  value       = helm_release.aws_load_balancer_controller.status
}
