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

output "security_group_id" {
  description = "Module security group, attached to the cluster"
  value       = aws_security_group.main.id
}

output "instance_identifiers" {
  description = "Instance identifiers, in instance order"
  value       = aws_rds_cluster_instance.main[*].identifier
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN of the RDS-managed master password; null with a caller password"
  value       = try(aws_rds_cluster.main.master_user_secret[0].secret_arn, null)
}

output "internal_records" {
  description = "Internal CNAMEs by key (primary: writer, ro: reader) as { name, fqdn }; empty when internal_dns is null"
  value       = { for key, record in aws_route53_record.internal : key => { name = record.name, fqdn = record.fqdn } }
}
