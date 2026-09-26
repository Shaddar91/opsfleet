resource "aws_route53_record" "r53" {
  count   = var.alias ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain_name
  type    = var.type_of_dns_record
  ttl     = var.ttl
  records = var.records_list
  alias {
    name                   = var.resource_alias
    zone_id                = var.resource_zone
    evaluate_target_health = var.health_check
  }
}