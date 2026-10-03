resource "aws_route53_record" "r53" {
  count   = local.create_record ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain_name
  type    = var.type_of_dns_record
  ttl     = var.alias ? null : var.ttl
  records = var.alias ? null : var.records_list
  dynamic "alias" {
    for_each = var.alias ? [1] : []
    content {
      name                   = var.resource_alias
      zone_id                = var.resource_zone
      evaluate_target_health = var.health_check
    }
  }
}
