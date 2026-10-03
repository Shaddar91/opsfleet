resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${local.name}-vpc"
  }
}
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.name}-default-security-group-DO-NOT-USE"
  }
}
module "flow_logs_role" {
  count         = var.flow_logs_iam_role_arn == null ? 1 : 0
  source        = "../../iam/role"
  custom_policy = true

  name        = "${local.name}-vpc-flow-logs"
  aws_service = "vpc-flow-logs.amazonaws.com"
  policy_file = file("${path.module}/files/policies/flow-logs-policy.json")
}
resource "aws_flow_log" "main" {
  iam_role_arn    = var.flow_logs_iam_role_arn != null ? var.flow_logs_iam_role_arn : module.flow_logs_role[0].role_arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = var.flow_logs_traffic_type
  vpc_id          = aws_vpc.main.id
  log_format      = var.flow_logs_custom_format ? "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${flow-direction}" : null
  tags = {
    "Name" = "${local.name}-vpc-flow-log"
  }
}
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "${local.name}-vpc-flow-logs"
  retention_in_days = var.flow_logs_retention_days
  kms_key_id        = var.flow_logs_kms_encryption ? (var.flow_logs_kms_key_id != null ? var.flow_logs_kms_key_id : aws_kms_key.flow_logs[0].arn) : null
}
resource "aws_kms_key" "flow_logs" {
  count                   = var.flow_logs_kms_encryption && var.flow_logs_kms_key_id == null ? 1 : 0
  description             = "KMS key for ${local.name} VPC flow logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy = templatefile("${path.module}/files/policies/kms-flow-logs-policy.json", {
    ACCOUNT_ID     = data.aws_caller_identity.current.account_id
    REGION         = var.region
    LOG_GROUP_NAME = "${local.name}-vpc-flow-logs"
  })
  tags = {
    Name = "${local.name}-flow-logs-kms"
  }
}
resource "aws_kms_alias" "flow_logs" {
  count         = var.flow_logs_kms_encryption && var.flow_logs_kms_key_id == null ? 1 : 0
  name          = "alias/${local.name}-flow-logs"
  target_key_id = aws_kms_key.flow_logs[0].key_id
}
