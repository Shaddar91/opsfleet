module "firehose_role" {
  count         = var.enable_waf ? 1 : 0
  source        = "../../iam/role"
  environment   = var.environment
  application   = "${var.application}-firehose-stream"
  custom_policy = true
  aws_service   = "firehose.amazonaws.com"
  policy_file = templatefile(
    "${path.module}/files/firehose_policy.json",
    { bucket = "${var.environment}-${var.application}-logs" }
  )
}
