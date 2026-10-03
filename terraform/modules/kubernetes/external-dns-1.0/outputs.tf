output "role_arn" {
  description = "ARN of the external-dns role, bound to external-dns/external-dns by Pod Identity"
  value       = module.external_dns_role.role_arn
}
