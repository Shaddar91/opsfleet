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