variable "region" {
  description = "Region of the state bucket; tfctl.sh sets it from STATE_BUCKET_REGION"
  type        = string
}

variable "state_bucket_name" {
  description = "Name of the state bucket; tfctl.sh sets it from STATE_BUCKET"
  type        = string
}

variable "force_destroy" {
  description = "Let destroy delete the bucket while it still holds objects; a change takes effect only after an apply"
  type        = bool
}

variable "create_state_bucket" {
  description = "Create and manage the state bucket; false reads the account's existing bucket and leaves it untouched. Export TF_VAR_create_state_bucket"
  type        = bool
}
