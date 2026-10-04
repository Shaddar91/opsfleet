variable "application" {
  type = string
}
variable "environment" {
  type = string
}
variable "port" {
  type        = number
  description = "Port number for the target group"
  default     = 80
}

variable "protocol" {
  type        = string
  description = "May be required, Forces new resource) Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda"
  default     = "HTTP"
}

variable "vpc_id" {
  type = string
}
variable "target_type" {
  type        = string
  description = "(May be required, Forces new resource) Type of target that you must specify when registering targets with this target group. See doc for supported values. The default is instance.Note that you can't specify targets for a target group using both instance IDs and IP addresses If the target type is ip, specify IP addresses from the subnets of the virtual private cloud (VPC) for the target group, the RFC 1918 range (10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16), and the RFC 6598 range (100.64.0.0/10). You can't specify publicly routable IP addresses. Network Load Balancers do not support the lambda target type.Application Load Balancers do not support the alb target type."
  default     = "instance"
}

variable "resrouce_id" {
  type        = string
  description = "ID's of resrouces for target group attachemnt"
}

variable "alb_listener_cert_enabled" {
  type        = bool
  description = "Enable disable Certificate creation"
  default     = true
}

variable "listener_arn" {
  type        = string
  description = "value"
}

variable "certificate_arn" {
  type    = string
  default = null
}

variable "domain_name" {
  type = string
}
variable "priority" {
  type = number
}
variable "health_check_path" {
  type    = string
  default = "/"
}

variable "health_check_protocol" {
  type    = string
  default = "HTTP"
}