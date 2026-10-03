output "repository_url" {
  description = "URL of the of-failover ECR repository, <registry>/<name>; CI pushes images here"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the of-failover ECR repository"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the of-failover ECR repository"
  value       = module.ecr.repository_name
}
