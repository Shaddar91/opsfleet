variable "application" {
  description = "Name part of the accelerator: <environment>-<application>-accelerator"
  type        = string
}

variable "enabled" {
  description = "Accept and route traffic; false stops it while the accelerator keeps its static IPs"
  type        = bool
}

variable "create_route53_health_check" {
  description = "Create a Route53 TCP health check on the accelerator DNS name; it gates no record"
  type        = bool
}

variable "app_subdomain" {
  description = "Label under the public zone; <app_subdomain>.<zone domain> aliases the accelerator and is the hostname every region's edge serves"
  type        = string
}
