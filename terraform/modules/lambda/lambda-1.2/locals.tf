locals {
  name                       = "${var.environment}-${var.application}-${var.function_name}"
  basic_execution_policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
