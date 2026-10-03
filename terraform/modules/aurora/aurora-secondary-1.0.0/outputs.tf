output "cluster_identifier" {
  description = "Cluster identifier"
  value       = aws_rds_cluster.main.cluster_identifier
}

output "cluster_arn" {
  description = "Cluster ARN"
  value       = aws_rds_cluster.main.arn
}

output "endpoint" {
  description = "Cluster endpoint hostname, the writer once the cluster is promoted to primary"
  value       = aws_rds_cluster.main.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint hostname, load-balanced across the cluster instances"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "port" {
  description = "Database port"
  value       = aws_rds_cluster.main.port
}

output "security_group_id" {
  description = "Module security group, attached to the cluster"
  value       = aws_security_group.main.id
}
