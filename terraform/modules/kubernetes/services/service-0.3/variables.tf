variable "environment" {
  type = string
}

variable "application" {
  type = string
}

variable "fqdn" {
  type = string

  validation {
    condition     = trimspace(var.fqdn) != ""
    error_message = "The fqdn value must be non-empty."
  }
}

variable "zone_id" {
  type = string

  validation {
    condition     = trimspace(var.zone_id) != ""
    error_message = "The zone_id value must be non-empty."
  }
}

variable "listener_arn" {
  type = string

  validation {
    condition     = trimspace(var.listener_arn) != ""
    error_message = "The listener_arn value must be non-empty."
  }
}

variable "alias_target_dns_name" {
  type = string

  validation {
    condition     = trimspace(var.alias_target_dns_name) != ""
    error_message = "The alias_target_dns_name value must be non-empty."
  }
}

variable "alias_target_zone_id" {
  type = string

  validation {
    condition     = trimspace(var.alias_target_zone_id) != ""
    error_message = "The alias_target_zone_id value must be non-empty."
  }
}

variable "priority" {
  type = number

  validation {
    condition     = var.priority >= 1 && var.priority <= 50000 && floor(var.priority) == var.priority
    error_message = "The priority value must be a whole number from 1 to 50000."
  }
}

variable "extra_conditions" {
  type = list(object({
    type   = string
    name   = optional(string)
    values = list(string)
  }))
  default = []
}

variable "vpc_id" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "pod_security_group_id" {
  type = string
}

variable "create_security_group_rule" {
  type    = bool
  default = true
}

variable "create_certificate" {
  type    = bool
  default = true
}

variable "container_port" {
  type = number

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535 && floor(var.container_port) == var.container_port
    error_message = "The container_port value must be a whole number from 1 to 65535."
  }
}

variable "health_check_path" {
  type = string
}

variable "health_check_matcher" {
  type    = string
  default = "200-399"
}

variable "deregistration_delay" {
  type    = number
  default = 30
}

variable "argo_application_path" {
  type = string
}

variable "argocd_namespace" {
  type = string
}

variable "repo_url" {
  type = string
}

variable "target_revision" {
  type = string
}

variable "chart_path" {
  type = string
}

variable "namespace" {
  type = string
}

variable "argocd_project" {
  type    = string
  default = "default"
}

variable "namespace_labels" {
  type    = map(string)
  default = {}
}

variable "architecture" {
  type = string

  validation {
    condition     = contains(["arm64", "amd64"], var.architecture)
    error_message = "The architecture value must be arm64 or amd64."
  }
}

variable "chart_files" {
  type    = map(string)
  default = {}
}
