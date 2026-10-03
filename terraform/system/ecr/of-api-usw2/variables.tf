variable "repository_name" {
  description = "Name of the replica repository, the same name as the us-east-1 of-api repository"
  type        = string
}

variable "force_delete" {
  description = "Let destroy delete the repository while it still holds images; a change takes effect only after an apply"
  type        = bool
}
