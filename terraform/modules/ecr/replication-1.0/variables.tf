variable "destination_regions" {
  type        = list(string)
  description = "Regions the matching repositories are replicated to, in this account"

  validation {
    condition     = length(var.destination_regions) > 0 && length(var.destination_regions) <= 25
    error_message = "destination_regions needs 1 to 25 regions (ECR allows 25 destinations per rule)."
  }
}

variable "repository_prefixes" {
  type        = list(string)
  description = "Repository name prefixes the rule applies to; a prefix also matches longer names that start with it"

  validation {
    condition     = length(var.repository_prefixes) > 0 && length(var.repository_prefixes) <= 100
    error_message = "repository_prefixes needs 1 to 100 prefixes (ECR allows 100 filters per rule)."
  }
}
