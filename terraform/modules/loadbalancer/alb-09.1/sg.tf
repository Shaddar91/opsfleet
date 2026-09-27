locals {
  default_rules_cidr = concat(
    var.accept_http ? [{ type = "ingress", from_port = 80, to_port = 80, protocol = "tcp", cidrs = ["0.0.0.0/0"] }] : [],
    [
      { type = "ingress", from_port = 443, to_port = 443, protocol = "tcp", cidrs = ["0.0.0.0/0"] },
      { type = "egress", from_port = 0, to_port = 0, protocol = "-1", cidrs = [var.vpc_cidr] },
    ]
  )
}

module "alb_sg" {
  source      = "../../sg/"
  name        = "${var.environment}-${var.application}"
  environment = var.environment
  vpc_id      = var.vpc_id
  rules_cidr  = var.rules_cidr == null ? local.default_rules_cidr : var.rules_cidr
  application = var.application
}
