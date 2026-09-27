resource "aws_eip" "nat" {
  count = local.nat_count
  tags = {
    Name = var.one_nat_gateway_per_az ? "${local.name}-nat-ip-${count.index + 1}" : "${local.name}-nat-ip"
  }
}

resource "aws_nat_gateway" "main" {
  count         = local.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.one_nat_gateway_per_az ? count.index : var.ngw_public_subnet_index].id
  tags = {
    Name = var.one_nat_gateway_per_az ? "${local.name}-ngw-${count.index + 1}" : "${local.name}-ngw"
  }
}
