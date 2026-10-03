#A aliases for web_fqdn and the zone apex to the distribution, IPv4 only; Route53 rejects target-health evaluation on a CloudFront alias.

module "web_alias" {
  source       = "../../../../modules/r53/r53-1.2-merged"
  alias        = true
  health_check = false

  for_each = toset([local.web_fqdn, local.public_zone_domain_name])

  zone_id            = local.public_zone_id
  domain_name        = each.key
  type_of_dns_record = "A"
  resource_alias     = module.cloudfront.domain_name
  resource_zone      = module.cloudfront.hosted_zone_id
}


module "cert" {
  source = "../../../../modules/aws-pub-cert/certificate-1.0-merged"

  environment               = var.environment
  application               = var.application
  region                    = "us-east-1"
  domain_name               = local.web_fqdn
  subject_alternative_names = [local.public_zone_domain_name]
  route53_zone_id           = local.public_zone_id
}
