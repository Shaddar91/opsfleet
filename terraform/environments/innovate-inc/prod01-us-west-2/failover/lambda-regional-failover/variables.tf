variable "image_tag" {
  description = "Tag of the of-failover image the function runs, the git commit the CI pushed"
  type        = string
}

variable "primary_environment" {
  description = "Environment name of the region that writes today, its aurora and edge state keys"
  type        = string
}

variable "primary_region" {
  description = "AWS region of the primary environment"
  type        = string
}

variable "standby_environment" {
  description = "Environment name of the standby region, its aurora and edge state keys"
  type        = string
}

variable "standby_region" {
  description = "AWS region of the standby environment, the default target of a failover"
  type        = string
}

variable "on_alarm" {
  description = "Action the function takes on a CloudWatch alarm event: status reports only, failover promotes the standby"
  type        = string

  validation {
    condition     = contains(["status", "failover"], var.on_alarm)
    error_message = "on_alarm must be status or failover."
  }
}

variable "timeout" {
  description = "Seconds an invocation may run; a failover waits for the promotion within it"
  type        = number
}

variable "memory_size" {
  description = "Memory of the function in MB"
  type        = number
}
