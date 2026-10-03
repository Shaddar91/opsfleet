data "aws_route53_zone" "service" {
  zone_id = local.public_zone_id
}
