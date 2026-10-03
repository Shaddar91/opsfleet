variable "repository_name" {
  description = "Name of the backend ECR repository, the of-api image"
  type        = string
}

variable "force_delete" {
  description = "Let destroy delete the repository while it still holds images; a change takes effect only after an apply"
  type        = bool
}

variable "api_repository" {
  description = "of-api's repository name, without the owner: this stack sets its Actions secrets and commits its .github/workflows/ci.yml"
  type        = string
}

variable "snyk_token" {
  description = "Snyk token the repo's snyk job runs with, set as its SNYK_TOKEN Actions secret; replace it before it expires. Lives only in the git-ignored secrets.auto.tfvars"
  type        = string
  sensitive   = true

  validation {
    condition     = nonsensitive(var.snyk_token != "")
    error_message = "snyk_token is empty: set it in the git-ignored secrets.auto.tfvars."
  }
}
