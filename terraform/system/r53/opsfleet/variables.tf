variable "domain_name" {
  description = "Public zone name, a subdomain of parent_zone_name; export TF_VAR_domain_name from the env file outside the repo"
  type        = string
}

variable "parent_zone_name" {
  description = "Existing public hosted zone in this account that receives the two delegations; export TF_VAR_parent_zone_name from the env file outside the repo"
  type        = string

  validation {
    condition     = endswith(var.domain_name, ".${var.parent_zone_name}")
    error_message = "domain_name must be a subdomain of parent_zone_name, e.g. app.example.com under example.com."
  }
}
