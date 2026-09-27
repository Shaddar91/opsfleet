variable "enabled" {
  type    = bool
  default = true
}

variable "environment" {
  type = string
}

variable "application" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "subject_alternative_names" {
  type    = list(any)
  default = []
}

variable "region" {
  type        = string
  default     = null
  description = "Region of the certificate and its validation; null uses the provider region. A CloudFront viewer certificate must be in us-east-1."
}
