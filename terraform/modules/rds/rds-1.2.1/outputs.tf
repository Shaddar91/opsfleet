output "identifier" {
  description = "Primary instance identifier"
  value       = aws_db_instance.main.identifier
}

output "resource_id" {
  description = "Primary DBI resource ID, the rds-db:connect resource for IAM authentication"
  value       = aws_db_instance.main.resource_id
}

output "arn" {
  description = "Primary instance ARN"
  value       = aws_db_instance.main.arn
}

output "address" {
  description = "Primary instance hostname"
  value       = aws_db_instance.main.address
}

output "endpoint" {
  description = "Primary instance endpoint, address:port"
  value       = aws_db_instance.main.endpoint
}

output "port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "engine" {
  description = "Database engine"
  value       = aws_db_instance.main.engine
}

output "engine_version" {
  description = "Running engine version, also when engine_version is a prefix"
  value       = aws_db_instance.main.engine_version_actual
}

output "kms_key_id" {
  description = "KMS key ARN of the storage encryption"
  value       = aws_db_instance.main.kms_key_id
}

output "hosted_zone_id" {
  description = "Canonical hosted zone ID of the primary endpoint"
  value       = aws_db_instance.main.hosted_zone_id
}

output "security_group_id" {
  description = "Module security group, attached to the primary and the replicas"
  value       = aws_security_group.main.id
}

output "replica_identifiers" {
  description = "Replica identifiers, in replica order"
  value       = aws_db_instance.replica[*].identifier
}

output "replica_addresses" {
  description = "Replica hostnames, in replica order"
  value       = aws_db_instance.replica[*].address
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN of the RDS-managed master password; null with a caller password"
  value       = try(aws_db_instance.main.master_user_secret[0].secret_arn, null)
}

output "internal_records" {
  description = "Internal CNAMEs by key (primary, ro, ro1, ...) as { name, fqdn }; empty when internal_dns is null"
  value       = { for key, record in aws_route53_record.internal : key => { name = record.name, fqdn = record.fqdn } }
}
