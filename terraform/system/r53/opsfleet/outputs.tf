output "zone_id" {
  description = "Public zone id, where the environment stacks publish their records"
  value       = module.public_zone.zone_id
}

output "domain_name" {
  description = "Public zone name"
  value       = module.public_zone.name
}

output "name_servers" {
  description = "Public zone name servers"
  value       = module.public_zone.name_servers
}

output "arn" {
  description = "Public zone ARN"
  value       = module.public_zone.arn
}

output "internal_zone_id" {
  description = "Internal zone id"
  value       = module.internal_zone.zone_id
}

output "internal_domain_name" {
  description = "Internal zone name"
  value       = module.internal_zone.name
}

output "internal_name_servers" {
  description = "Internal zone name servers"
  value       = module.internal_zone.name_servers
}

output "internal_arn" {
  description = "Internal zone ARN"
  value       = module.internal_zone.arn
}

output "parent_zone_id" {
  description = "Id of the parent zone both delegations live in"
  value       = data.aws_route53_zone.parent.zone_id
}

output "parent_zone_name" {
  description = "Name of the parent zone"
  value       = var.parent_zone_name
}
