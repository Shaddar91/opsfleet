output "repository_url" {
  description = "URL of the of-launch repository, <registry>/<name>"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the of-launch repository"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the of-launch repository"
  value       = module.ecr.repository_name
}
