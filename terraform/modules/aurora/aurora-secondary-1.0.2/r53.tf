#Internal CNAMEs in the caller's private zone: <name> to the cluster endpoint, <name>-ro to the reader endpoint.

resource "aws_route53_record" "internal" {
  for_each = local.internal_records
  zone_id  = var.internal_dns.zone_id
  name     = each.value.name
  type     = "CNAME"
  ttl      = var.internal_dns.ttl
  records  = [each.value.target]
}
