#Lambda@Edge: one published function in us-east-1, code rendered from a template at plan time, log group kept for log_retention_days.

data "archive_file" "code" {
  type        = "zip"
  output_path = "${path.root}/.terraform/${local.name}.zip"

  source {
    content  = templatefile(var.source_template, var.template_vars)
    filename = "index.js"
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/us-east-1.${local.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "main" {
  function_name    = local.name
  role             = module.role.role_arn
  handler          = "index.handler"
  runtime          = var.runtime
  publish          = true
  filename         = data.archive_file.code.output_path
  source_code_hash = data.archive_file.code.output_base64sha256
  timeout          = 5
  memory_size      = 128

  depends_on = [aws_cloudwatch_log_group.main, module.role]
}
