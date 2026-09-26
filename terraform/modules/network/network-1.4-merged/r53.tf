resource "aws_route53_record" "subdomain_ns" {
  count   = var.create_internal_hosted_zone ? 1 : 0
  name    = "${var.internal_zone_name}."
  type    = var.r53_record_type
  ttl     = var.r53_ttl
  records = aws_route53_zone.internal_zone[count.index].name_servers
  zone_id = var.zone_id
}

resource "aws_route53_zone" "internal_zone" {
  count = var.create_internal_hosted_zone ? 1 : 0
  name  = "${var.internal_zone_name}."
  vpc {
    vpc_id     = aws_vpc.main.id
    vpc_region = var.region
  }
  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}