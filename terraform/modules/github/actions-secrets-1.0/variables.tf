variable "repository" {
  description = "Repository name, without the owner"
  type        = string
}

variable "secrets" {
  description = "Actions secrets, name to plaintext value"
  type        = map(string)
  default     = {}
  sensitive   = true

  validation {
    condition     = alltrue([for k in nonsensitive(keys(var.secrets)) : can(regex("^[A-Za-z_][A-Za-z0-9_]*$", k)) && !startswith(upper(k), "GITHUB_")])
    error_message = "Secret names take letters, digits and underscores, and must not start with a digit or GITHUB_"
  }
}

variable "variables" {
  description = "Actions variables, name to value"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.variables) : can(regex("^[A-Za-z_][A-Za-z0-9_]*$", k)) && !startswith(upper(k), "GITHUB_")])
    error_message = "Variable names take letters, digits and underscores, and must not start with a digit or GITHUB_"
  }
}
