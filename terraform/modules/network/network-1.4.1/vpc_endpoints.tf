resource "aws_vpc_endpoint" "s3" {
  count        = var.enable_s3_endpoint ? 1 : 0
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.nat[*].id,
    [aws_route_table.internal.id]
  )
  tags = {
    Name = "${local.name}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2" {
  count               = var.enable_ec2_endpoint ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [module.ec2_endpoint_sg[0].sg_id]
  tags = {
    Name = "${local.name}-ec2-vpce"
  }
}

module "ec2_endpoint_sg" {
  count       = var.enable_ec2_endpoint ? 1 : 0
  source      = "../../sg/"
  environment = var.environment
  application = "ec2-vpce"
  vpc_id      = aws_vpc.main.id
  rules_sg = [
    for sg in var.ec2_endpoint_allowed_sg_ids : {
      type      = "ingress"
      source_sg = sg
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
    }
  ]
}
