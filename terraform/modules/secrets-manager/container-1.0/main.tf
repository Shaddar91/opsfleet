#Secrets Manager secret without a Terraform-managed version: the value is written and rotated outside Terraform.

resource "aws_secretsmanager_secret" "main" {
  name        = var.name
  description = var.description
  tags        = { Name = var.name }
}
