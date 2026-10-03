data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {
  count = var.end_to_end_iam_auth == null ? 0 : 1
}
