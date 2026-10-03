#Route53 alias: the module's Global Accelerator if created, else the external one, else the ALB.
#create_route53_record = false disables it (DNS managed elsewhere).

module "r53_alias" {
  count = var.create_route53_record ? 1 : 0

  source       = "../../r53/r53-1.2-merged/"
  alias        = true
  health_check = true

  zone_id            = var.hosted_zone_id
  domain_name        = var.domain_name
  type_of_dns_record = "A"

  resource_alias = local.route53_target_dns
  resource_zone  = local.route53_target_zone

  depends_on = [
    aws_lb.main
  ]
}

module "cert" {
  count           = var.create_certificate ? 1 : 0
  source          = "../../aws-pub-cert/certificate-1.0"
  application     = var.application
  environment     = var.environment
  route53_zone_id = var.hosted_zone_id
  domain_name     = var.domain_name
}
