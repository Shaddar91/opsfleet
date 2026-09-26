#----------------------------------------------------------
#Route53 DNS Record
#----------------------------------------------------------
#Routing priority:
#  1. create_global_accelerator = true → points to internal GA
#  2. use_external_global_accelerator = true → points to external GA
#  3. Both false → points directly to ALB
#Set create_route53_record = false to disable (manage DNS elsewhere)

locals {
  #determine where Route53 should point
  route53_target_dns = (
    var.create_global_accelerator ? aws_globalaccelerator_accelerator.main[0].dns_name :
    var.use_external_global_accelerator ? var.external_global_accelerator_dns_name :
    aws_lb.main.dns_name
  )

  route53_target_zone = (
    var.create_global_accelerator ? aws_globalaccelerator_accelerator.main[0].hosted_zone_id :
    var.use_external_global_accelerator ? var.external_global_accelerator_zone_id :
    aws_lb.main.zone_id
  )
}

module "r53_alias" {
  count = var.create_route53_record ? 1 : 0

  source             = "../../r53/r53-1.2/"
  alias              = true
  zone_id            = var.hosted_zone_id
  domain_name        = var.domain_name
  type_of_dns_record = "A"

  resource_alias = local.route53_target_dns
  resource_zone  = local.route53_target_zone

  health_check = true

  depends_on = [
    aws_lb.main
  ]
}

#----------------------------------------------------------
#ACM Certificate
#----------------------------------------------------------

module "cert" {
  count           = var.create_certificate ? 1 : 0
  source          = "../../aws-pub-cert/certificate-1.0"
  application     = var.application
  environment     = var.environment
  route53_zone_id = var.hosted_zone_id
  domain_name     = var.domain_name
}
