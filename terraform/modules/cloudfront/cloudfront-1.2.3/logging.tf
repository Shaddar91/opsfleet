resource "aws_cloudwatch_log_delivery_source" "main" {
  count        = var.enable_logging ? 1 : 0
  region       = "us-east-1"
  name         = substr("${local.name}-access", 0, 60)
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.main.arn
  tags         = local.tags
}

resource "aws_cloudwatch_log_delivery_destination" "main" {
  count         = var.enable_logging ? 1 : 0
  region        = "us-east-1"
  name          = substr("${local.name}-s3", 0, 60)
  output_format = var.log_output_format

  delivery_destination_configuration {
    destination_resource_arn = var.log_bucket_arn
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_delivery" "main" {
  count                    = var.enable_logging ? 1 : 0
  region                   = "us-east-1"
  delivery_source_name     = aws_cloudwatch_log_delivery_source.main[0].name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.main[0].arn
  tags                     = local.tags
}
