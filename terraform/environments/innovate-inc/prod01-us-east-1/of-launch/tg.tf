#Target group and host rule on the edge ALB's HTTPS listener for the public name.

module "tg_of_launch" {
  source                    = "../../../../modules/tg/tg-02"
  alb_listener_cert_enabled = true

  application           = var.application
  environment           = var.environment
  port                  = 8080
  protocol              = "HTTP"
  target_type           = "instance"
  health_check_path     = "/login"
  health_check_protocol = "HTTP"
  vpc_id                = local.vpc_id
  resrouce_id           = tostring(module.of_launch_01.ec2_id)
  listener_arn          = local.alb_https_listener_arn
  certificate_arn       = module.cert_of_launch.arn
  domain_name           = local.fqdn
  priority              = var.alb_priority

  depends_on = [module.cert_of_launch, module.of_launch_01]
}
