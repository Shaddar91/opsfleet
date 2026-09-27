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
  count  = local.private_rt_count
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.one_nat_gateway_per_az ? "${local.name}-private-rt-${count.index + 1}" : "${local.name}-private-rt"
  }
}

moved {
  from = aws_route_table.nat
  to   = aws_route_table.nat[0]
}

resource "aws_route" "nat" {
  count = var.create_nat_gateway && !var.enable_tgw_routing ? local.private_rt_count : 0

  route_table_id         = aws_route_table.nat[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route" "tgw" {
  count = var.enable_tgw_routing ? local.private_rt_count : 0

  route_table_id         = aws_route_table.nat[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route_table" "internal" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-internal"
  }
}
