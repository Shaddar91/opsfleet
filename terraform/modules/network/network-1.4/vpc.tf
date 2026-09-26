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
resource "aws_flow_log" "main" {
  iam_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.flow_logs_iam_role_name}"
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_vpc.main.id
  tags = {
    "Name" = "${local.name}-vpc-flow-log"
  }
}
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "${local.name}-vpc-flow-logs"
  retention_in_days = 60
}