output "master_user_secret_arn" {
  description = "the chart's db.secretArn; the pod's service account needs secretsmanager:GetSecretValue on it, pod identity or IRSA, wired in the components tier"
  value       = module.aurora.master_user_secret_arn
}

output "writer_endpoint" {
  description = "Writer endpoint hostname, the chart's DB_HOST"
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

output "master_user_secret_replica_arns" {
  description = "Master user secret replica ARNs by region, the db.secretArn of a chart in that region"
  value       = module.aurora.master_user_secret_replica_arns
}
