output "registry_id" {
  description = "Registry the configuration belongs to, the account id"
  value       = aws_ecr_replication_configuration.main.registry_id
}

output "destination_regions" {
  description = "Regions images are replicated to"
  value       = var.destination_regions
}
