#Proxy security group (client ingress, egress to the database and Secrets Manager) and the database-side ingress from it.

resource "aws_security_group" "main" {
  name        = "${local.name}-sg"
  description = "RDS-Proxy-(terraform-managed)"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name}-sg"
    Environment = var.environment
  }
}

#count, not for_each: a group or CIDR created in the same apply is unknown at plan.
resource "aws_vpc_security_group_ingress_rule" "security_group" {
  count = length(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.main.id
  referenced_security_group_id = var.allowed_security_group_ids[count.index]
  description                  = "Proxy port from an allowed security group"
  ip_protocol                  = "tcp"
  from_port                    = local.proxy_port
  to_port                      = local.proxy_port
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  count = length(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.main.id
  cidr_ipv4         = var.allowed_cidr_blocks[count.index]
  description       = "Proxy port from an allowed CIDR block"
  ip_protocol       = "tcp"
  from_port         = local.proxy_port
  to_port           = local.proxy_port
}

resource "aws_vpc_security_group_egress_rule" "database" {
  security_group_id            = aws_security_group.main.id
  referenced_security_group_id = var.target_security_group_id
  description                  = "Database port to the target"
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
}

resource "aws_vpc_security_group_egress_rule" "secrets_manager" {
  count = length(var.secrets_manager_egress_cidrs)

  security_group_id = aws_security_group.main.id
  cidr_ipv4         = var.secrets_manager_egress_cidrs[count.index]
  description       = "HTTPS to Secrets Manager"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "database_from_proxy" {
  security_group_id            = var.target_security_group_id
  referenced_security_group_id = aws_security_group.main.id
  description                  = "Database port from the RDS Proxy"
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
}
