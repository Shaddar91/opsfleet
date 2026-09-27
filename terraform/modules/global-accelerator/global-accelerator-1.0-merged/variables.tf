variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod) — used to compose resource names."
}

variable "application" {
  type        = string
  description = "Application name — used to compose resource names alongside environment."
}

variable "accelerator_name" {
  type        = string
  description = "Explicit accelerator name override. Defaults to $${environment}-$${application}-accelerator when null."
  default     = null
}

variable "enabled" {
  type        = bool
  description = "Whether the Global Accelerator is enabled at the AWS level."
  default     = true
}

variable "ip_address_type" {
  type        = string
  description = "IP address type for the accelerator. IPV4 or DUAL_STACK."
  default     = "IPV4"

  validation {
    condition     = contains(["IPV4", "DUAL_STACK"], var.ip_address_type)
    error_message = "ip_address_type must be IPV4 or DUAL_STACK."
  }
}

variable "flow_logs" {
  type = object({
    s3_bucket = string
    s3_prefix = optional(string, "global-accelerator/")
  })
  description = "Flow-logs S3 destination. Set to null to disable flow logs."
  default     = null
}

variable "listeners" {
  type = map(object({
    protocol        = optional(string, "TCP")
    client_affinity = optional(string, "NONE")
    port_ranges = list(object({
      from_port = number
      to_port   = number
    }))
    endpoint_group = optional(object({
      region                        = optional(string)
      health_check_protocol         = optional(string, "TCP")
      health_check_port             = optional(number, 443)
      health_check_path             = optional(string, "/")
      health_check_interval_seconds = optional(number, 30)
      threshold_count               = optional(number, 3)
      traffic_dial_percentage       = optional(number, 100)
      endpoints = list(object({
        endpoint_id                    = string
        weight                         = optional(number, 100)
        client_ip_preservation_enabled = optional(bool, true)
      }))
    }))
  }))
  description = "Map of listeners keyed by logical name. Each listener can optionally declare an endpoint_group block that ties endpoints (ALB/NLB/EIP/EC2) into the listener."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.listeners : contains(["TCP", "UDP"], coalesce(v.protocol, "TCP"))])
    error_message = "Each listener.protocol must be TCP or UDP."
  }

  validation {
    condition     = alltrue([for k, v in var.listeners : contains(["NONE", "SOURCE_IP"], coalesce(v.client_affinity, "NONE"))])
    error_message = "Each listener.client_affinity must be NONE or SOURCE_IP."
  }

  validation {
    condition     = alltrue([for k, v in var.listeners : contains(["TCP", "HTTP", "HTTPS"], v.endpoint_group.health_check_protocol) if v.endpoint_group != null])
    error_message = "Each endpoint_group.health_check_protocol must be TCP, HTTP or HTTPS."
  }

  validation {
    condition     = alltrue([for k, v in var.listeners : contains([10, 30], v.endpoint_group.health_check_interval_seconds) if v.endpoint_group != null])
    error_message = "Each endpoint_group.health_check_interval_seconds must be 10 or 30."
  }

  validation {
    condition     = alltrue([for k, v in var.listeners : v.endpoint_group.traffic_dial_percentage >= 0 && v.endpoint_group.traffic_dial_percentage <= 100 if v.endpoint_group != null])
    error_message = "Each endpoint_group.traffic_dial_percentage must be between 0 and 100."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged onto the accelerator and the Route53 health check."
  default     = {}
}

variable "create_route53_health_check" {
  type        = bool
  description = "Create a Route53 TCP health check on the accelerator DNS name. The module attaches it to no record."
  default     = false
}

variable "route53_health_check_port" {
  type        = number
  description = "Port the Route53 health check probes on the accelerator."
  default     = 443
}

variable "route53_health_check_failure_threshold" {
  type        = number
  description = "Consecutive Route53 health-check failures before the accelerator is marked unhealthy."
  default     = 3
}

variable "route53_health_check_request_interval" {
  type        = number
  description = "Seconds between Route53 health checks. 10 or 30."
  default     = 10

  validation {
    condition     = contains([10, 30], var.route53_health_check_request_interval)
    error_message = "route53_health_check_request_interval must be 10 or 30."
  }
}
