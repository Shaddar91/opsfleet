locals {
  name = coalesce(var.name, "${var.environment}-${var.application}-cf-web-acl")

  tags = {
    Name        = local.name
    Environment = var.environment
    Terraform   = "true"
  }
}
