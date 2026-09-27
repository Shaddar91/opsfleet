output "accelerator" {
  description = "The whole aws_globalaccelerator_accelerator resource."
  value       = aws_globalaccelerator_accelerator.main
}

output "accelerator_arn" {
  description = "ARN of the Global Accelerator."
  value       = aws_globalaccelerator_accelerator.main.arn
}

output "accelerator_id" {
  description = "ID of the Global Accelerator."
  value       = aws_globalaccelerator_accelerator.main.id
}

output "dns_name" {
  description = "DNS name of the Global Accelerator — alias this from your Route 53 zone."
  value       = aws_globalaccelerator_accelerator.main.dns_name
}

output "hosted_zone_id" {
  description = "Route 53 hosted-zone ID for the Global Accelerator (use in alias records)."
  value       = aws_globalaccelerator_accelerator.main.hosted_zone_id
}

output "static_ip_addresses" {
  description = "Static IP addresses assigned to the accelerator (flattened across all ip_sets)."
  value       = flatten([for s in aws_globalaccelerator_accelerator.main.ip_sets : s.ip_addresses])
}

output "ip_sets" {
  description = "Raw ip_sets attribute (full structure including ip_family) for the accelerator."
  value       = aws_globalaccelerator_accelerator.main.ip_sets
}

output "listener_arns" {
  description = "Map of listener-key → listener ARN."
  value       = { for k, v in aws_globalaccelerator_listener.main : k => v.arn }
}

output "listeners" {
  description = "Map of listener-key → whole aws_globalaccelerator_listener resource."
  value       = aws_globalaccelerator_listener.main
}

output "endpoint_group_arns" {
  description = "Map of listener-key → endpoint-group ARN (only for listeners that declared an endpoint_group block)."
  value       = { for k, v in aws_globalaccelerator_endpoint_group.main : k => v.arn }
}

output "endpoint_groups" {
  description = "Map of listener-key → whole aws_globalaccelerator_endpoint_group resource (only for listeners that declared an endpoint_group block)."
  value       = aws_globalaccelerator_endpoint_group.main
}

output "route53_health_check" {
  description = "The whole aws_route53_health_check resource, or null when create_route53_health_check is false."
  value       = one(aws_route53_health_check.main)
}

output "route53_health_check_id" {
  description = "ID of the Route53 health check, or null when create_route53_health_check is false."
  value       = one(aws_route53_health_check.main[*].id)
}
