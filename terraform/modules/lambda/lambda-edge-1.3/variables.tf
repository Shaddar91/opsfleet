variable "environment" {
  description = "Environment part of the function name"
  type        = string
}

variable "application" {
  description = "Application part of the function name"
  type        = string
}

variable "function_name" {
  description = "Last part of the function name: <environment>-<application>-<function_name>"
  type        = string
}

variable "source_template" {
  description = "Path of the function's JavaScript template; it becomes index.js and must export handler"
  type        = string
}

variable "template_vars" {
  description = "Values substituted into source_template"
  type        = map(string)
  default     = {}
}

variable "runtime" {
  description = "Lambda runtime; nodejs24.x is the newest GA Node.js runtime and takes async handlers only"
  type        = string
  default     = "nodejs24.x"
}

variable "log_retention_days" {
  description = "Retention of the us-east-1 log group; other edge regions create their own groups at the first invocation"
  type        = number
  default     = 30
}
