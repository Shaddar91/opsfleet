output "accelerator_dns_name" {
  description = "DNS name of the accelerator, the alias target of the app record"
  value       = module.global_accelerator.dns_name
}

output "static_ips" {
  description = "The accelerator's static anycast IPv4 addresses, held until the accelerator is deleted"
  value       = module.global_accelerator.static_ip_addresses
}

output "app_fqdn" {
  description = "Hostname whose A alias points at the accelerator"
  value       = aws_route53_record.app.fqdn
}
