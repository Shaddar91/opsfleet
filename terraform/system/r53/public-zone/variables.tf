variable "domain_name" {
  description = "Domain the public zone serves; export TF_VAR_domain_name from the env file outside the repo"
  type        = string
}

variable "force_destroy" {
  description = "Let destroy delete the zone while it still holds records made outside this stack; a change takes effect only after an apply"
  type        = bool
  default     = true
}

variable "delegation_set_id" {
  description = "Reusable delegation set, so the zone keeps the same four name servers across unroll and roll; null lets Route53 assign new ones"
  type        = string
  default     = null
}

variable "null_mail" {
  description = "Publish SPF v=spf1 -all and DMARC p=reject for a domain that sends no mail; set false before adding real mail records"
  type        = bool
  default     = true
}
