output "accelerator_dns_name" {
  description = "DNS name of the accelerator, the alias target of the app record"
  value       = module.global_accelerator.dns_name
}

output "accelerator_hosted_zone_id" {
  description = "Route 53 zone id for alias records that target the accelerator"
  value       = module.global_accelerator.hosted_zone_id
}

output "static_ips" {
  description = "The accelerator's static anycast IPv4 addresses, held until the accelerator is deleted"
  value       = module.global_accelerator.static_ip_addresses
}

output "listener_arn" {
  description = "The web listener (TCP 80 and 443) every region's edge stack attaches its ALB to"
  value       = module.global_accelerator.listener_arns["web"]
}

output "app_fqdn" {
  description = "Hostname whose A alias points at the accelerator; every region's edge serves it"
  value       = aws_route53_record.app.fqdn
}
