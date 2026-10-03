output "zone_id" {
  description = "Hosted zone id"
  value       = aws_route53_zone.this.zone_id
}

output "name" {
  description = "Zone name, the FQDN records are published under"
  value       = var.name
}

output "name_servers" {
  description = "Name servers of the zone, the delegation record's values"
  value       = aws_route53_zone.this.name_servers
}

output "arn" {
  description = "Hosted zone ARN"
  value       = aws_route53_zone.this.arn
}

output "private" {
  description = "True when the zone answers only inside its VPCs"
  value       = length(var.private_vpc_ids) > 0
}
