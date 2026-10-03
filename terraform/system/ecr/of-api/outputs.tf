output "repository_url" {
  description = "URL of the backend repository, <registry>/<name>; CI pushes images here"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the backend repository"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the backend repository"
  value       = module.ecr.repository_name
}
