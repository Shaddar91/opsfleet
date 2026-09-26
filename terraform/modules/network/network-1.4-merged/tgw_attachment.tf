//=============================================================================
// Transit Gateway VPC Attachment
//=============================================================================
// Phase 1: Enable TGW attachment (safe, no traffic impact)
// Creates ENIs in specified subnets and attaches VPC to Transit Gateway
// Traffic continues to use NAT until enable_tgw_routing is set to true

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.enable_tgw_attachment ? 1 : 0

  subnet_ids         = var.tgw_attachment_subnet_ids != null ? var.tgw_attachment_subnet_ids : aws_subnet.private[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main.id

  dns_support  = "enable"
  ipv6_support = "disable"

  tags = {
    Name        = "${local.name}-tgw-attachment"
    Environment = var.environment
    ManagedBy   = "terraform"
    Purpose     = "centralized-egress"
  }
}
