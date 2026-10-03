output "cluster_identifier" {
  description = "Cluster identifier, the db_cluster_identifier of an RDS Proxy target"
  value       = aws_rds_cluster.main.cluster_identifier
}

output "cluster_resource_id" {
  description = "Cluster resource ID, the rds-db:connect resource for IAM authentication"
  value       = aws_rds_cluster.main.cluster_resource_id
}

output "cluster_arn" {
  description = "Cluster ARN"
  value       = aws_rds_cluster.main.arn
}

output "endpoint" {
  description = "Writer endpoint hostname"
  value       = aws_rds_cluster.main.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint hostname, load-balanced across the readers; the writer while the cluster has no reader"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "port" {
  description = "Database port"
  value       = aws_rds_cluster.main.port
}

output "engine" {
  description = "Database engine"
  value       = aws_rds_cluster.main.engine
}

output "engine_version" {
  description = "Engine version the cluster runs, the version a secondary cluster joins with"
  value       = aws_rds_cluster.main.engine_version_actual
}

output "global_cluster_identifier" {
  description = "Global database identifier, the global_cluster_identifier of a secondary cluster; null without create_global_cluster"
  value       = try(aws_rds_global_cluster.main[0].id, null)
}

output "global_cluster_arn" {
  description = "Global database ARN; null without create_global_cluster"
  value       = try(aws_rds_global_cluster.main[0].arn, null)
}

output "global_writer_endpoint" {
  description = "Global writer endpoint hostname, which follows the primary cluster across regions; null without create_global_cluster"
  value       = try(aws_rds_global_cluster.main[0].endpoint, null)
}

output "security_group_id" {
  description = "Module security group, attached to the cluster"
  value       = aws_security_group.main.id
}

output "instance_identifiers" {
  description = "Instance identifiers, in instance order"
  value       = aws_rds_cluster_instance.main[*].identifier
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN of the master user secret: the module secret with create_master_user_secret, the RDS-managed one otherwise; null with a caller password"
  value       = var.create_master_user_secret ? local.master_user_secret_arn : try(aws_rds_cluster.main.master_user_secret[0].secret_arn, null)
}

output "master_user_secret_replica_arns" {
  description = "Replica ARNs of the module secret by region; Secrets Manager gives a replica the primary ARN with its own region. Empty without create_master_user_secret"
  value       = local.master_user_secret_replica_arns
}

output "internal_records" {
  description = "Internal CNAMEs by key (primary: writer, ro: reader) as { name, fqdn }; empty when internal_dns is null"
  value       = { for key, record in aws_route53_record.internal : key => { name = record.name, fqdn = record.fqdn } }
}
