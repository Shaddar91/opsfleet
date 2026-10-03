variable "repository" {
  type        = string
  description = "Repository name, without the owner"
}

variable "default_workflow_permissions" {
  type        = string
  default     = "read"
  nullable    = false
  description = "GITHUB_TOKEN default: read or write; jobs raise what they need with a permissions block"

  validation {
    condition     = contains(["read", "write"], var.default_workflow_permissions)
    error_message = "default_workflow_permissions must be read or write."
  }
}

variable "can_approve_pull_request_reviews" {
  type        = bool
  default     = false
  nullable    = false
  description = "Let workflows create and approve pull requests with GITHUB_TOKEN; release-please needs it to open its release pull request"
}
