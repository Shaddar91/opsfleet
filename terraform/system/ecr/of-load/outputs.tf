output "repository_url" {
  description = "URL of the of-load ECR repository, <registry>/<name>; CI pushes images here"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the of-load ECR repository"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the of-load ECR repository"
  value       = module.ecr.repository_name
}
