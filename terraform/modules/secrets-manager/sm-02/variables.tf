#Secrets Manager module inputs.
variable "environment" {
  description = "Environment name used in the secret name and tags."
  type        = string
}

variable "application" {
  description = "Application name used in the secret name and tags."
  type        = string
}

variable "secrets" {
  description = "Secret values serialized into the managed secret version."
  type        = map(string)
  sensitive   = true
}

variable "description" {
  description = "Optional description for the managed secret."
  type        = string
  default     = null
}
