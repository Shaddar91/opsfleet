variable "repository" {
  description = "Repository whose Terraform pipeline assumes these roles, without the owner"
  type        = string
}

variable "apply_environment" {
  description = "GitHub environment the apply job runs in; only its jobs can assume the apply role"
  type        = string
}
