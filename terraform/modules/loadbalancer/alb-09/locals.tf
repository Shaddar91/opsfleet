locals {
  bucket = "${var.environment}-${var.application}-alb-logs"

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
