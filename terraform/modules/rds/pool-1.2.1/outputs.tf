output "proxy_name" {
  description = "Proxy name, <environment>-<application>-pool"
  value       = aws_db_proxy.main.name
}

output "proxy_arn" {
  description = "Proxy ARN; its last segment (prx-...) is the resource ID clients name in rds-db:connect"
  value       = aws_db_proxy.main.arn
}

output "endpoint" {
  description = "Proxy endpoint hostname"
  value       = aws_db_proxy.main.endpoint
}

output "security_group_id" {
  description = "Proxy security group"
  value       = aws_security_group.main.id
}

output "role_arn" {
  description = "Role the proxy uses: the created one, or the given role"
  value       = local.role_arn
  depends_on  = [module.role]
}

output "internal_records" {
  description = "Internal CNAME by key (pool) as { name, fqdn }; empty when internal_dns is null"
  value       = { for key, record in aws_route53_record.internal : key => { name = record.name, fqdn = record.fqdn } }
}
