variable "repository_name" {
  description = "Name of the of-launch image repository"
  type        = string
}

variable "force_delete" {
  description = "Let destroy delete the repository while it still holds images; a change takes effect only after an apply"
  type        = bool
}
