output "repository_url" {
  description = "The of-helm repository Argo CD is tied to"
  value       = local.helm_repo_url
}

output "project_names" {
  description = "AppProjects the argocd-apps release renders"
  value       = keys(local.projects)
}

output "application_names" {
  description = "Applications the argocd-apps release renders"
  value       = keys(local.applications)
}
