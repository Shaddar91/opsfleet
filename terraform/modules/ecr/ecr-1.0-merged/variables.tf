#ECR Repository Module Variables

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, stage, prod, shared)"
  type        = string
  default     = "shared"
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE"
  }
}

variable "force_delete" {
  description = "Delete the repository even if it still contains images"
  type        = bool
  default     = true
}

variable "scan_on_push" {
  description = "Enable vulnerability scanning on image push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type (AES256 or KMS)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either AES256 or KMS"
  }
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption (required if encryption_type is KMS)"
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "Lifecycle policy JSON document; null creates no lifecycle policy"
  type        = string
  default     = null

  validation {
    condition     = var.lifecycle_policy == null || can(jsondecode(var.lifecycle_policy))
    error_message = "lifecycle_policy must be a JSON document"
  }
}

variable "enable_cross_account_access" {
  description = "Enable cross-account access to ECR repository"
  type        = bool
  default     = false
}

variable "allowed_account_ids" {
  description = "List of AWS account IDs allowed to pull images (when cross-account access is enabled)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to the repository"
  type        = map(string)
  default     = {}
}
