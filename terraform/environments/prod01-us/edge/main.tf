#prod01-us edge: public ALB with ACM, HTTP to HTTPS redirect, WAF and access logs; ../global-accelerator owns DNS.

locals {
  app_fqdn = "${var.app_subdomain}.${local.public_zone_domain_name}"
}

module "alb" {
  source = "../../../modules/loadbalancer/alb-09.1"

  application = var.application
  environment = var.environment
  vpc_id      = local.vpc_id
  vpc_cidr    = local.vpc_cidr
  subnet_ids  = local.public_subnets

  internal                   = false
  enable_deletion_protection = var.enable_deletion_protection
  accept_http                = true

  create_certificate = true
  hosted_zone_id     = local.public_zone_id
  domain_name        = local.app_fqdn

  create_route53_record           = false
  create_global_accelerator       = false
  use_external_global_accelerator = false

  enable_waf                = true
  rate_limit                = var.waf_rate_limit
  enable_waf_whitelist      = false
  waf_allowed_paths         = []
  aws_common_excluded_rules = []

  bucket_versioning        = "Disabled"
  expire_days              = var.log_expire_days
  log_bucket_name          = var.edge_log_bucket_name
  log_bucket_force_destroy = var.log_bucket_force_destroy
}
