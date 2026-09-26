resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-public-rt"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-private-rt"
  }
}

//=============================================================================
// Route for Private Subnets - Toggleable between NAT and TGW
//=============================================================================

// Route via NAT Gateway (default, traditional approach)
resource "aws_route" "nat" {
  count = var.enable_tgw_routing ? 0 : 1

  route_table_id         = aws_route_table.nat.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

// Route via Transit Gateway (centralized egress)
// Phase 2: Enable this after TGW attachment is confirmed working
resource "aws_route" "tgw" {
  count = var.enable_tgw_routing ? 1 : 0

  route_table_id         = aws_route_table.nat.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route_table" "internal" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-internal"
  }
}