#Public name through the Global Accelerator, its certificate, and the internal name.

module "r53_of_launch_public" {
  source       = "../../../../modules/r53/r53-1.2-merged"
  alias        = true
  health_check = false

  zone_id            = local.public_zone_id
  domain_name        = local.fqdn
  type_of_dns_record = "A"
  resource_alias     = local.accelerator_dns_name
  resource_zone      = local.accelerator_hosted_zone_id
}

module "cert_of_launch" {
  source = "../../../../modules/aws-pub-cert/certificate-1.0"

  application     = var.application
  environment     = var.environment
  route53_zone_id = local.public_zone_id
  domain_name     = local.fqdn
}

module "r53_of_launch_internal" {
  source = "../../../../modules/r53/r53-1.2-merged"

  zone_id            = local.internal_zone_id
  domain_name        = var.internal_domain
  type_of_dns_record = "A"
  records_list       = [module.of_launch_01.private_ip]
}
