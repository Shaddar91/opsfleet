module "role" {
  source        = "../../iam/role"
  custom_policy = true

  name               = local.name
  assume_role_policy = file("${path.module}/files/trust/lambda-edge.json")
  policy_file        = file("${path.module}/files/policies/logs.json")
}
