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
  default = 300
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

variable "skip_empty_alias_target" {
  type        = bool
  default     = false
  description = "Create no alias record when resource_alias or resource_zone is null or empty. Both must be known at plan time"
}

variable "health_check" {
  type    = bool
  default = null
}