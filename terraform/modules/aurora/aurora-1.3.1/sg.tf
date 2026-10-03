#Module security group: database-port ingress from the allowed groups and CIDR blocks, no egress rule.

resource "aws_security_group" "main" {
  name        = "${var.environment}-${var.application}-aurora-sg"
  description = "Aurora-cluster-(terraform-managed)"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-${var.application}-aurora-sg"
    Environment = var.environment
  }
}

#count, not for_each: a group or CIDR created in the same apply is unknown at plan.
resource "aws_vpc_security_group_ingress_rule" "security_group" {
  count = length(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.main.id
  referenced_security_group_id = var.allowed_security_group_ids[count.index]
  description                  = "Database port from an allowed security group"
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  count = length(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.main.id
  cidr_ipv4         = var.allowed_cidr_blocks[count.index]
  description       = "Database port from an allowed CIDR block"
  ip_protocol       = "tcp"
  from_port         = var.port
  to_port           = var.port
}
