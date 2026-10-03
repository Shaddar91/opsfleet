variable "environment" {
  description = "Environment name, the first part of the function name"
  type        = string
}

variable "application" {
  description = "Application name, the second part of the function name"
  type        = string
}

variable "function_name" {
  description = "Last part of the function name: the function is <environment>-<application>-<function_name>"
  type        = string
}

variable "description" {
  description = "Function description"
  type        = string
  default     = null
}

variable "image_uri" {
  description = "Image the function runs, <repository_url>:<tag>, from an ECR repository in the function's region"
  type        = string
}

variable "architecture" {
  description = "Instruction set the image was built for, arm64 or x86_64"
  type        = string
  default     = "arm64"
}

variable "timeout" {
  description = "Seconds an invocation may run, at most 900"
  type        = number
  default     = 60
}

variable "memory_size" {
  description = "Memory in MB"
  type        = number
  default     = 256
}

variable "environment_variables" {
  description = "Environment variables the function reads"
  type        = map(string)
  default     = {}
}

variable "policy_file" {
  description = "IAM policy JSON of what the function may call, attached to its role beside AWSLambdaBasicExecutionRole"
  type        = string
}

variable "log_retention_days" {
  description = "Days CloudWatch keeps the function's log group"
  type        = number
  default     = 30
}

variable "reserved_concurrent_executions" {
  description = "Concurrency reserved for the function; null leaves it unreserved"
  type        = number
  default     = null
}
