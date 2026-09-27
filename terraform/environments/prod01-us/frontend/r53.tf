#A and AAAA aliases for web_fqdn to the distribution; Route53 rejects target-health evaluation on a CloudFront alias.

module "web_alias" {
  source   = "../../../modules/r53/r53-1.2-merged"
  for_each = toset(["A", "AAAA"])

  zone_id            = local.public_zone_id
  domain_name        = local.web_fqdn
  type_of_dns_record = each.key
  alias              = true
  resource_alias     = module.cloudfront.domain_name
  resource_zone      = module.cloudfront.hosted_zone_id
  health_check       = false
}
