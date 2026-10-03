#Lambda function from a container image in ECR, with its log group and execution role.

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "main" {
  function_name                  = local.name
  description                    = var.description
  role                           = module.role.role_arn
  package_type                   = "Image"
  image_uri                      = var.image_uri
  architectures                  = [var.architecture]
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = var.environment_variables
  }

  depends_on = [aws_cloudwatch_log_group.main, module.role]
}
