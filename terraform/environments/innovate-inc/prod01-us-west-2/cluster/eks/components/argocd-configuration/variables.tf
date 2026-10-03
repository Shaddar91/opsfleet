variable "argocd_namespace" {
  description = "Namespace Argo CD runs in; the repository credential and the argocd-apps release go there"
  type        = string
}

variable "argocd_chart_repository" {
  description = "Helm repository of the argocd-apps chart"
  type        = string
}

variable "argocd_apps_chart_version" {
  description = "argocd-apps Helm chart version, an exact X.Y.Z pin"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.argocd_apps_chart_version))
    error_message = "argocd_apps_chart_version must be an exact X.Y.Z pin, e.g. 2.0.6; a range lets the chart move without a commit."
  }
}

variable "helm_repo_credentials" {
  description = "Username and read token for the of-helm repository; the value lives only in the git-ignored secrets.auto.tfvars"
  type = object({
    username = string
    password = string
  })
  sensitive = true
}

variable "projects" {
  description = "Argo CD AppProjects the argocd-apps chart renders, keyed by name; sourceRepos always starts with the of-helm repository"
  type        = map(any)
}

variable "applications" {
  description = "Argo CD Applications the argocd-apps chart renders, keyed by name; source.repoURL defaults to the of-helm repository's HTTPS URL"
  type        = map(any)
}
