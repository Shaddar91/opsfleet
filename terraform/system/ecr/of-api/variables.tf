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
