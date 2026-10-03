//alias record fqdn -> the edge ALB

module "record" {
  source       = "../../../r53/r53-1.2-merged"
  alias        = true
  health_check = true

  zone_id            = var.zone_id
  domain_name        = var.fqdn
  type_of_dns_record = "A"
  resource_alias     = var.alias_target_dns_name
  resource_zone      = var.alias_target_zone_id
}

module "certificate" {
  source = "../../../aws-pub-cert/certificate-1.0"

  enabled         = var.create_certificate
  route53_zone_id = var.zone_id
  domain_name     = var.fqdn
  environment     = var.environment
  application     = var.application
}

resource "aws_lb_listener_certificate" "this" {
  count = var.create_certificate ? 1 : 0

  listener_arn    = var.listener_arn
  certificate_arn = module.certificate.validated_arn
}
 