output "zone_id" {
  description = "Id of the public hosted zone"
  value       = aws_route53_zone.public.zone_id
}

output "name_servers" {
  description = "Name servers to delegate to at the registrar"
  value       = aws_route53_zone.public.name_servers
}

output "domain_name" {
  description = "Domain the zone serves"
  value       = aws_route53_zone.public.name
}

output "arn" {
  description = "ARN of the public hosted zone"
  value       = aws_route53_zone.public.arn
}
