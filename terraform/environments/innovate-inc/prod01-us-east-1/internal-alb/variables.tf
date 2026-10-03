variable "internal_ingress_hosts" {
  description = "Host headers the HTTP listener forwards to the internal ingress target group; [] means *.internal.<public zone domain>"
  type        = list(string)

  validation {
    condition     = length(var.internal_ingress_hosts) <= 3
    error_message = "An ALB host-header condition takes at most 3 values."
  }
}

variable "ingress_rule_priority" {
  description = "Priority of the internal ingress listener rule; a service rule for a host it also matches needs a lower number"
  type        = number
}

variable "enable_deletion_protection" {
  description = "Block ALB deletion; false lets tfctl.sh destroy remove it"
  type        = bool
}
