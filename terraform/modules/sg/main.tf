resource "aws_security_group" "main" {
  name   = var.name == null ? "${var.environment}-${var.application}-sg" : "${var.name}-sg"
  vpc_id = var.vpc_id
  tags = {
    Name = var.name == null ? "${var.environment}-${var.application}-sg" : "${var.name}-sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "rule_sg" {
  count                    = length(var.rules_sg)
  type                     = var.rules_sg[count.index].type
  from_port                = var.rules_sg[count.index].from_port
  to_port                  = var.rules_sg[count.index].to_port
  protocol                 = var.rules_sg[count.index].protocol
  security_group_id        = aws_security_group.main.id
  source_security_group_id = var.rules_sg[count.index].source_sg
}
resource "aws_security_group_rule" "rule_cidr" {
  count             = length(var.rules_cidr)
  type              = var.rules_cidr[count.index].type
  from_port         = var.rules_cidr[count.index].from_port
  to_port           = var.rules_cidr[count.index].to_port
  protocol          = var.rules_cidr[count.index].protocol
  security_group_id = aws_security_group.main.id
  cidr_blocks       = var.rules_cidr[count.index].cidrs
}
resource "aws_security_group_rule" "rule_self" {
  count             = length(var.rules_self)
  type              = var.rules_self[count.index].type
  from_port         = var.rules_self[count.index].from_port
  to_port           = var.rules_self[count.index].to_port
  protocol          = var.rules_self[count.index].protocol
  security_group_id = aws_security_group.main.id
  self              = true
}