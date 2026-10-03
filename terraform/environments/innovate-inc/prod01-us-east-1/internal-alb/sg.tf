#Internal ALB security group: HTTP and HTTPS in from the VPC CIDR, egress to the VPC CIDR only.

resource "aws_security_group" "alb" {
  name        = "${var.environment}-internal-alb-sg"
  description = "Internal ALB: HTTP and HTTPS from the VPC, egress to the VPC"
  vpc_id      = local.vpc_id

  tags = {
    Name        = "${var.environment}-internal-alb-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc" {
  for_each = { http = 80, https = 443 }

  security_group_id = aws_security_group.alb.id
  description       = "${upper(each.key)} from the VPC"
  cidr_ipv4         = local.vpc_cidr
  ip_protocol       = "tcp"
  from_port         = each.value
  to_port           = each.value

  tags = {
    Name        = "${var.environment}-internal-alb-${each.key}-in"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_egress_rule" "vpc" {
  security_group_id = aws_security_group.alb.id
  description       = "All traffic to the VPC: targets and their health checks"
  cidr_ipv4         = local.vpc_cidr
  ip_protocol       = "-1"

  tags = {
    Name        = "${var.environment}-internal-alb-vpc-out"
    Environment = var.environment
  }
}
