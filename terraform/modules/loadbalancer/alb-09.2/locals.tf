locals {
  bucket = var.log_bucket_name

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

  default_rules_cidr = concat(
    var.accept_http ? [{ type = "ingress", from_port = 80, to_port = 80, protocol = "tcp", cidrs = ["0.0.0.0/0"] }] : [],
    [
      { type = "ingress", from_port = 443, to_port = 443, protocol = "tcp", cidrs = ["0.0.0.0/0"] },
      { type = "egress", from_port = 0, to_port = 0, protocol = "-1", cidrs = [var.vpc_cidr] },
    ]
  )
}
