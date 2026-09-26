module "ec2_sg" {
  source      = "../../sg"
  name        = "${var.environment}-${var.application}"
  environment = var.environment
  vpc_id      = var.vpc_id
  rules_cidr  = var.rules_cidr
  rules_sg    = var.rules_sg
  application = var.application
}
