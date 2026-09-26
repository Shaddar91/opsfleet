resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0
  tags = {
    Name = "${local.name}-nat-ip"
  }
}

resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.ngw_public_subnet_index].id
  tags = {
    Name = "${local.name}-ngw"
  }
}
