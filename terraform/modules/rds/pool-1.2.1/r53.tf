#Internal CNAME <name>-pool to the proxy endpoint, in the caller's private zone.

resource "aws_route53_record" "internal" {
  for_each = local.internal_records
  zone_id  = var.internal_dns.zone_id
  name     = each.value.name
  type     = "CNAME"
  ttl      = var.internal_dns.ttl
  records  = [each.value.target]
}
