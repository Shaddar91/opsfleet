output "repo_name" {
  description = "Repository name"
  value       = module.repo.repo_name
}

output "repo_full_name" {
  description = "Repository name as owner/name"
  value       = module.repo.full_name
}

output "repo_id" {
  description = "Numeric GitHub repository ID"
  value       = module.repo.repo_id
}
