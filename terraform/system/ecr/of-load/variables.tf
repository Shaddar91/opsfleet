variable "repository_name" {
  description = "Name of the ECR repository for the of-load image"
  type        = string
}

variable "force_delete" {
  description = "Let destroy delete the repository while it still holds images; a change takes effect only after an apply"
  type        = bool
}

variable "load_repository" {
  description = "of-load's repository name, without the owner: this stack sets its Actions secrets and commits its .github/workflows/ci.yml"
  type        = string
}
