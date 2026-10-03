output "dns_url" {
  value = resource.aws_route53_record.r53
}

output "fqdn" {
  value = one(aws_route53_record.r53[*].fqdn)
}
