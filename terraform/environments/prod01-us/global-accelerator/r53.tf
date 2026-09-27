#The app hostname's A alias to the accelerator; no AAAA while the ALB and the accelerator are IPv4-only.

resource "aws_route53_record" "app" {
  zone_id = local.public_zone_id
  name    = local.app_fqdn
  type    = "A"

  alias {
    name                   = module.global_accelerator.dns_name
    zone_id                = module.global_accelerator.hosted_zone_id
    evaluate_target_health = false
  }
}
