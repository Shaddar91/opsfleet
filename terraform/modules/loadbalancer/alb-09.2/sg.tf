module "alb_sg" {
  source      = "../../sg/"
  name        = "${var.environment}-${var.application}"
  environment = var.environment
  vpc_id      = var.vpc_id
  rules_cidr  = var.rules_cidr == null ? local.default_rules_cidr : var.rules_cidr
  application = var.application
}
