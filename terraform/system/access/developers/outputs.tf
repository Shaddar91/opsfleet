output "group_name" {
  description = "IAM group to add a developer's IAM user to; membership is the only per-person step"
  value       = module.group.group_name
}

output "group_arn" {
  description = "ARN of the developer group"
  value       = module.group.arn
}

output "deploy_role_arn" {
  description = "Role group members assume for kubectl; its access entry grants AmazonEKSEditPolicy in var.namespaces only"
  value       = module.deploy_role.role_arn
}

output "kubeconfig_command" {
  description = "What a group member runs once, with their own IAM user credentials, to point kubectl at the cluster as the deploy role"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${local.cluster_name} --role-arn ${module.deploy_role.role_arn} && kubectl config set-context --current --namespace ${var.namespaces[0]}"
}
