output "repository_url" {
  description = "URL of the replica repository, <registry>/<name>; the us-west-2 cluster pulls from here"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the replica repository"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the replica repository"
  value       = module.ecr.repository_name
}
