variable "destination_regions" {
  description = "Regions the matching repositories are replicated to"
  type        = list(string)
}

variable "repository_prefixes" {
  description = "Repository name prefixes the rule applies to"
  type        = list(string)
}
