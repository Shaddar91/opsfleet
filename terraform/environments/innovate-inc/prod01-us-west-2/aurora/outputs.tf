output "endpoint" {
  description = "Cluster endpoint hostname, the writer once this cluster is promoted to primary"
  value       = module.aurora.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint hostname of this cluster"
  value       = module.aurora.reader_endpoint
}

output "port" {
  description = "Database port, the chart's DB_PORT"
  value       = module.aurora.port
}

output "database_name" {
  description = "Database of the global cluster, the chart's DB_NAME"
  value       = local.database_name
}

output "global_writer_endpoint" {
  description = "Global writer endpoint hostname; it follows the primary cluster across regions"
  value       = local.global_writer_endpoint
}

output "database_secret_arn" {
  description = "This region's database secret, read by the backends by Pod Identity and by the proxy"
  value       = module.database_secret.arn
}

output "database_secret_name" {
  description = "Database secret name, the chart's secrets.db.name in this region"
  value       = module.database_secret.name
}

output "cluster_arn" {
  description = "ARN of this cluster, the target of failover-global-cluster when this region is promoted"
  value       = module.aurora.cluster_arn
}

output "pool_endpoint" {
  description = "RDS Proxy endpoint hostname"
  value       = module.pool.endpoint
}

output "pool_internal_fqdn" {
  description = "Internal name of the RDS Proxy, the chart's DB_HOST"
  value       = module.pool.internal_records["pool"].fqdn
}

output "internal_records" {
  description = "Internal CNAMEs by key (primary: cluster endpoint, ro: reader, pool: proxy) as { name, fqdn }"
  value       = merge(module.aurora.internal_records, module.pool.internal_records)
}
