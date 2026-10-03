output "database_secret_arn" {
  description = "Database secret the backends read by Pod Identity and the proxy authenticates with"
  value       = module.database_secret.arn
}

output "database_secret_name" {
  description = "Database secret name, the chart's secrets.db.name"
  value       = module.database_secret.name
}

output "master_username" {
  description = "Master username, the username a secondary region's secret carries"
  value       = var.master_username
}

output "writer_endpoint" {
  description = "Writer endpoint hostname; the API connects through pool_internal_fqdn"
  value       = module.aurora.endpoint
}

output "port" {
  description = "Database port, the chart's DB_PORT"
  value       = module.aurora.port
}

output "database_name" {
  description = "Database created with the cluster, the chart's DB_NAME"
  value       = var.database_name
}

output "global_cluster_identifier" {
  description = "Global database identifier, the global_cluster_identifier of a secondary cluster"
  value       = module.aurora.global_cluster_identifier
}

output "global_writer_endpoint" {
  description = "Global writer endpoint hostname; it follows the primary cluster across regions"
  value       = module.aurora.global_writer_endpoint
}

output "engine" {
  description = "Database engine, the engine of a secondary cluster"
  value       = module.aurora.engine
}

output "engine_version" {
  description = "Engine version the cluster runs, the engine_version of a secondary cluster"
  value       = module.aurora.engine_version
}

output "cluster_identifier" {
  description = "Cluster identifier"
  value       = module.aurora.cluster_identifier
}

output "cluster_arn" {
  description = "Cluster ARN"
  value       = module.aurora.cluster_arn
}

output "reader_endpoint" {
  description = "Reader endpoint hostname of this cluster"
  value       = module.aurora.reader_endpoint
}

output "global_cluster_arn" {
  description = "Global database ARN, the resource the regional failover Lambda promotes within"
  value       = module.aurora.global_cluster_arn
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
  description = "Internal CNAMEs by key (primary: writer, ro: reader, pool: proxy) as { name, fqdn }"
  value       = merge(module.aurora.internal_records, module.pool.internal_records)
}
