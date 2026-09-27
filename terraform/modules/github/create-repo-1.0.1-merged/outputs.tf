output "repo_name" {
  description = "Repository name"
  value       = github_repository.main.name
}

output "full_name" {
  description = "Repository name as owner/name"
  value       = github_repository.main.full_name
}

output "html_url" {
  description = "Repository web URL"
  value       = github_repository.main.html_url
}

output "repo_id" {
  description = "Numeric GitHub repository ID"
  value       = github_repository.main.repo_id
}
