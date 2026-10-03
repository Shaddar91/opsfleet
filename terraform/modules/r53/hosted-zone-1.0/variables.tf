variable "name" {
  description = "Fully qualified name of the hosted zone, for example of.example.com"
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9-]+\\.)+[a-z]{2,}$", var.name))
    error_message = "name must be a lower-case domain name without a trailing dot."
  }
}

variable "parent_zone_id" {
  description = "Hosted zone that receives the NS delegation record for name; null when nothing delegates to this zone"
  type        = string
  default     = null
}

variable "create_delegation" {
  description = "Write the NS record for name into parent_zone_id; ignored for a private zone"
  type        = bool
  default     = true
}

variable "mail_lockdown" {
  description = "Publish the records that refuse all mail for name: null MX, SPF -all, DMARC reject, DKIM revoked"
  type        = bool
  default     = true
}

variable "private_vpc_ids" {
  description = "VPCs a private zone answers in; empty makes the zone public"
  type        = list(string)
  default     = []
}

variable "comment" {
  description = "Comment shown in the Route 53 console"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags on the zone; Name is always set to name"
  type        = map(string)
  default     = {}
}
