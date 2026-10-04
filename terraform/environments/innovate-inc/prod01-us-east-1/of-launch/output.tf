output "of_launch_01_id" {
  value       = module.of_launch_01.ec2_id
  description = "of-launch EC2 instance ID"
}

output "of_launch_01_private_ip" {
  value       = module.of_launch_01.private_ip
  description = "of-launch private IP address"
}

output "of_launch_internal_dns" {
  value       = module.r53_of_launch_internal.fqdn
  description = "of-launch internal DNS name"
}

output "of_launch_public_dns" {
  value       = local.fqdn
  description = "Public DNS name of the dashboard"
}

output "of_launch_sg_id" {
  value       = module.of_launch_sg.sg.id
  description = "of-launch security group ID"
}

output "of_launch_iam_role_name" {
  value       = module.of_launch_01.iam_role.name
  description = "of-launch instance role name"
}

output "mysql_ebs_volume_id" {
  value       = aws_ebs_volume.mysql_data.id
  description = "EBS volume holding MySQL"
}

output "secrets_manager_name" {
  value       = module.sm.secrets_manager.name
  description = "Secrets Manager secret holding the app settings"
}

output "seed_sm_name" {
  value       = module.sm_seed.secrets_manager.name
  description = "Secrets Manager secret holding the seed users"
}

output "codedeploy_app_name" {
  value       = module.codedeploy.app.name
  description = "CodeDeploy application"
}

output "codedeploy_deployment_group" {
  value       = module.codedeploy.deployment_group.deployment_group_name
  description = "CodeDeploy deployment group, targeting the host by its Name tag"
}

output "cicd_role_arn" {
  value       = module.of_launch_cicd_role.role.arn
  description = "Role the deploy workflow assumes through OIDC"
}

output "github_secrets_deployed" {
  value       = keys(local.of_launch_github_secrets)
  description = "Actions secrets set on the of-launch repo"
}
