output "repository_url" {
  description = "URL of the frontend repository, <registry>/<name>"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the frontend repository"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the frontend repository"
  value       = module.ecr.repository_name
}
