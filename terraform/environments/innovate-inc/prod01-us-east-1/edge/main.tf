#prod01-us edge: public ALB with ACM, HTTP to HTTPS redirect, WAF and access logs, attached as this region's endpoint group to the innovate-inc accelerator, which owns the app hostname and its DNS.

module "alb" {
  source                          = "../../../../modules/loadbalancer/alb-09.2"
  internal                        = false
  accept_http                     = true
  create_certificate              = true
  create_route53_record           = false
  create_global_accelerator       = false
  use_external_global_accelerator = false
  attach_to_global_accelerator    = true
  enable_waf                      = true
  enable_waf_whitelist            = false

  application = var.application
  environment = var.environment
  vpc_id      = local.vpc_id
  vpc_cidr    = local.vpc_cidr
  subnet_ids  = local.public_subnets

  enable_deletion_protection = var.enable_deletion_protection

  hosted_zone_id = local.public_zone_id
  domain_name    = local.app_fqdn

  external_global_accelerator_listener_arn   = local.accelerator_listener_arn
  global_accelerator_traffic_dial_percentage = var.global_accelerator_traffic_dial_percentage

  rate_limit                = var.waf_rate_limit
  waf_allowed_paths         = []
  aws_common_excluded_rules = []

  bucket_versioning        = "Disabled"
  expire_days              = var.log_expire_days
  log_bucket_name          = var.edge_log_bucket_name
  log_bucket_force_destroy = var.log_bucket_force_destroy
}
