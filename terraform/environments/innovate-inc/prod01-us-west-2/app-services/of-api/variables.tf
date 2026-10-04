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



variable "argocd_project" {
  type        = string
  description = "Argo CD AppProject the Application belongs to; defined in the argocd components stack."
}

variable "web_subdomain" {
  type        = string
  description = "Label under the public zone the frontend is served on; https://<web_subdomain>.<zone domain> is the one browser origin the API answers, CORS_ALLOWED_ORIGINS in the app secret"
}

variable "token_ttl_seconds" {
  type        = number
  description = "Lifetime of a login token in seconds, TOKEN_TTL_SECONDS in the app secret"
}

variable "seed_user" {
  description = "Login the migration job creates after init-db; its password is seed_user_password"
  type        = string
}

variable "seed_user_password" {
  description = "Password of seed_user, written to the app secret and read by the migration job; lives only in the tier's git-ignored secrets.auto.tfvars"
  type        = string
  sensitive   = true
}

variable "db_migrate" {
  description = "Run the chart's schema step before each sync; true only in the region that holds the database writer"
  type        = bool
}
