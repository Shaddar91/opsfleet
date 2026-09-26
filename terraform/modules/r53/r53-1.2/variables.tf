variable "zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "type_of_dns_record" {
  type = string
}

variable "records_list" {
  type    = list(any)
  default = null
}

variable "ttl" {
  type    = string
  default = null
}

variable "alias" {
  type    = bool
  default = false
}

variable "resource_alias" {
  type    = string
  default = null
}

variable "resource_zone" {
  type    = string
  default = null
}

variable "health_check" {
  type    = bool
  default = null
}