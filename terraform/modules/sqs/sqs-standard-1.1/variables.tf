variable "application" {
  description = "Human-readable queue name segment."
  type        = string
}

variable "environment" {
  description = "Environment name used in queue names and tags."
  type        = string
}

variable "allowed_principal_arns" {
  description = "Additional AWS principal ARNs allowed to use the queue."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for arn in var.allowed_principal_arns : trimspace(arn) != ""])
    error_message = "Allowed principal ARNs must not be empty."
  }
}

variable "delay_seconds" {
  description = "Queue-wide delivery delay in seconds."
  type        = number
  default     = null

  validation {
    condition     = var.delay_seconds == null ? true : var.delay_seconds >= 0 && var.delay_seconds <= 900 && floor(var.delay_seconds) == var.delay_seconds
    error_message = "Delay seconds must be a whole number from 0 through 900."
  }
}

variable "max_message_size" {
  description = "Maximum message size in bytes."
  type        = number
  default     = 262144

  validation {
    condition     = var.max_message_size >= 1024 && var.max_message_size <= 262144 && floor(var.max_message_size) == var.max_message_size
    error_message = "Maximum message size must be a whole number from 1024 through 262144."
  }
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds."
  type        = number
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600 && floor(var.message_retention_seconds) == var.message_retention_seconds
    error_message = "Message retention must be a whole number from 60 through 1209600."
  }
}

variable "receive_wait_time_seconds" {
  description = "Long-poll wait time in seconds."
  type        = number
  default     = null

  validation {
    condition     = var.receive_wait_time_seconds == null ? true : var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20 && floor(var.receive_wait_time_seconds) == var.receive_wait_time_seconds
    error_message = "Receive wait time must be a whole number from 0 through 20."
  }
}

variable "sqs_managed_sse_enabled" {
  description = "Whether the main queue uses SQS-managed server-side encryption."
  type        = bool
  default     = false
  nullable    = false

  validation {
    condition     = contains([true, false], var.sqs_managed_sse_enabled)
    error_message = "SQS-managed server-side encryption must be true or false."
  }
}

variable "create_dlq" {
  description = "Whether to create an encrypted dead-letter queue and attach a redrive policy."
  type        = bool
  default     = false
  nullable    = false

  validation {
    condition     = contains([true, false], var.create_dlq)
    error_message = "Create DLQ must be true or false."
  }
}

variable "max_receive_count" {
  description = "Receive attempts before a message moves to the dead-letter queue."
  type        = number
  default     = 5

  validation {
    condition     = var.max_receive_count >= 1 && var.max_receive_count <= 1000 && floor(var.max_receive_count) == var.max_receive_count
    error_message = "Maximum receive count must be a whole number from 1 through 1000."
  }
}

variable "tags" {
  description = "Additional tags applied to all queues."
  type        = map(string)
  default     = {}
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds."
  type        = number
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200 && floor(var.visibility_timeout_seconds) == var.visibility_timeout_seconds
    error_message = "Visibility timeout must be a whole number from 0 through 43200."
  }
}

variable "allowed_service_principals" {
  description = "AWS service principals (for example events.amazonaws.com) allowed to send messages to the main queue."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for p in var.allowed_service_principals : can(regex("^[a-z0-9.-]+\\.amazonaws\\.com(\\.cn)?$", p))])
    error_message = "Each service principal must look like <service>.amazonaws.com."
  }
}

variable "enforce_tls" {
  description = "Whether the queue policy denies every request that is not made over TLS."
  type        = bool
  default     = false
  nullable    = false

  validation {
    condition     = contains([true, false], var.enforce_tls)
    error_message = "Enforce TLS must be true or false."
  }
}
