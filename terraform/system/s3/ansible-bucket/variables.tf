variable "ansible_bucket_name" {
  description = "Name of the Ansible bucket; export TF_VAR_ansible_bucket_name from the env file outside the repo"
  type        = string
}

variable "force_destroy" {
  description = "Let destroy delete the bucket while it still holds objects; a change takes effect only after an apply"
  type        = bool
  default     = true
}

variable "noncurrent_days" {
  description = "Days a replaced or deleted object version is kept before it expires"
  type        = number
}

variable "newer_noncurrent_versions" {
  description = "Newest noncurrent versions per object kept past noncurrent_days"
  type        = number
}

variable "abort_multipart_days" {
  description = "Days before an incomplete multipart upload is aborted"
  type        = number
}
