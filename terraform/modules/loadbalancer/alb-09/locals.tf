locals {
  bucket = "${var.environment}-${var.application}-alb-logs"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
