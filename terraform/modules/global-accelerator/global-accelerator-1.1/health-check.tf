resource "aws_route53_health_check" "main" {
  count = var.create_route53_health_check ? 1 : 0

  fqdn              = aws_globalaccelerator_accelerator.main.dns_name
  port              = var.route53_health_check_port
  type              = "TCP"
  failure_threshold = var.route53_health_check_failure_threshold
  request_interval  = var.route53_health_check_request_interval

  tags = merge(
    {
      Name        = "${local.name}-ga-health-check"
      Environment = var.environment
      Application = var.application
    },
    var.tags
  )
}
