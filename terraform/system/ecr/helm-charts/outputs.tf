output "repository_url" {
  description = "URL of the chart repository, <registry>/<namespace>/<chart name>; helm push targets oci://<registry>/<namespace>"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the chart repository"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the chart repository"
  value       = module.ecr.repository_name
}
