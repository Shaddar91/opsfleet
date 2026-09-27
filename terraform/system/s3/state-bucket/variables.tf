variable "region" {
  description = "Region of the state bucket; must equal STATE_BUCKET_REGION in the tier init.sh"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the state bucket; tfctl.sh sets it from STATE_BUCKET"
  type        = string
}

variable "force_destroy" {
  description = "Let destroy delete the bucket while it still holds objects; a change takes effect only after an apply"
  type        = bool
  default     = true
}
