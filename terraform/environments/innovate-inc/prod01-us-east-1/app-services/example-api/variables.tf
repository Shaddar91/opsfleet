variable "application" {
  type = string
}

variable "subdomain" {
  type = string
}

variable "container_port" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "priority" {
  type = number
}

variable "create_certificate" {
  type = bool
}

variable "create_security_group_rule" {
  type = bool
}

variable "namespace" {
  type = string
}

variable "architecture" {
  type = string
}

variable "argocd_namespace" {
  type = string
}

variable "git_repository" {
  type = string
}

variable "git_branch" {
  type = string
}

variable "git_path" {
  type = string
}

variable "commit_author" {
  type = string
}

variable "commit_email" {
  type = string
}

variable "argocd_project" {
  type        = string
  description = "Argo CD AppProject the Application belongs to; defined in the argocd components stack."
}
