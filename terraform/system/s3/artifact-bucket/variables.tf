variable "artifact_bucket_name" {
  description = "Name of the artifact bucket; export TF_VAR_artifact_bucket_name from the env file outside the repo"
  type        = string
}

variable "force_destroy" {
  description = "Let destroy delete the bucket while it still holds objects; a change takes effect only after an apply"
  type        = bool
}

variable "lifecycle_rule" {
  description = "Enable expiry for current objects under the artifact prefix"
  type        = bool
}

variable "expire_after" {
  description = "Days a current artifact is kept before it expires"
  type        = number
}

variable "prefix" {
  description = "Object prefix covered by artifact lifecycle rules"
  type        = string
}

variable "noncurrent_days" {
  description = "Days a replaced or deleted artifact version is kept before it expires"
  type        = number
}

variable "newer_noncurrent_versions" {
  description = "Newest noncurrent versions per artifact kept past noncurrent_days"
  type        = number
}

variable "abort_multipart_days" {
  description = "Days before an incomplete multipart upload is aborted"
  type        = number
}
