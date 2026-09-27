variable "project_name" {
  description = "Repository name"
  type        = string
  default     = "of-web"
}

variable "enable_branch_protection" {
  description = "Protect master; private repositories need a paid GitHub plan, so export TF_VAR_enable_branch_protection=false for a GitHub Free owner"
  type        = bool
  default     = true
}
