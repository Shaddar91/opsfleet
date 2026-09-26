variable "bucket" {
  type        = string
  description = "Name of the source bucket (the s3 module's s3_name output)"
}

variable "bucket_arn" {
  type        = string
  description = "ARN of the source bucket (the s3 module's arn output)"
}

variable "source_versioning_status" {
  type        = string
  description = "The s3 module's versioning_status output; replication needs Enabled"
}

variable "replica_bucket" {
  type        = string
  default     = null
  description = "Replica bucket name in the aws.replica region. Defaults to <bucket>-replica"
}

variable "source_kms" {
  type        = string
  default     = null
  description = "If the source bucket objects aren't being encrypted by the default Amazon S3 master-key (SSE-S3), then specify the KMS key ARN here."
}

variable "object_lock" {
  type        = bool
  default     = false
  description = "Enable Object Lock on the replica bucket; match the source bucket's object_lock"
}

variable "object_lock_mode" {
  type        = string
  default     = null
  description = "Default retention mode on the replica when Object Lock is enabled. Valid values are GOVERNANCE and COMPLIANCE."
}

variable "retention_years" {
  type        = number
  default     = null
  description = "Default retention period in years on the replica when Object Lock is enabled"
}
