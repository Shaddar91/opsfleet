variable "project_name" {
  description = "Repository name"
  type        = string
}

variable "enable_branch_protection" {
  description = "Protect master; private repositories need a paid GitHub plan, so export TF_VAR_enable_branch_protection=false for a GitHub Free owner"
  type        = bool
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
