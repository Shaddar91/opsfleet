variable "repository_name" {
  description = "Name of the backend ECR repository"
  type        = string
  default     = "backend"
}

variable "force_delete" {
  description = "Let destroy delete the repository while it still holds images; a change takes effect only after an apply"
  type        = bool
  default     = true
}
