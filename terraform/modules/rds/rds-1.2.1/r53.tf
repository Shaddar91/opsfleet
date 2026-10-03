#Internal CNAMEs in the caller's private zone: <name> to the primary, <name>-ro, <name>-ro1, ... to the replicas.

resource "aws_route53_record" "internal" {
  for_each = local.internal_records
  zone_id  = var.internal_dns.zone_id
  name     = each.value.name
  type     = "CNAME"
  ttl      = var.internal_dns.ttl
  records  = [each.value.target]
}
