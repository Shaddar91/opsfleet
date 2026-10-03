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

output "master_user_secret_arn" {
  description = "This region's replica of the master user secret, the chart's db.secretArn"
  value       = local.master_user_secret_arn
}
