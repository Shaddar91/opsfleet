#Proxy role, created only when no role is given: reads the auth secrets and, under end-to-end IAM authentication, connects as the listed users.

module "role" {
  count         = var.role == null ? 1 : 0
  source        = "../../iam/role"
  custom_policy = true

  name        = local.name
  aws_service = "rds.amazonaws.com"
  policy_file = local.role_policy
}
