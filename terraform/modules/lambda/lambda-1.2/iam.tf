module "role" {
  source        = "../../iam/role"
  custom_policy = true

  name        = local.name
  aws_service = "lambda.amazonaws.com"
  policy_file = var.policy_file
  policy_list = [local.basic_execution_policy_arn]
}
