module "firehose_role" {
  count         = var.enable_waf ? 1 : 0
  source        = "../../iam/role"
  custom_policy = true

  environment = var.environment
  application = "${var.application}-firehose-stream"
  aws_service = "firehose.amazonaws.com"
  policy_file = templatefile(
    "${path.module}/files/firehose_policy.json",
    { BUCKET = "${var.environment}-${var.application}-logs" }
  )
}
