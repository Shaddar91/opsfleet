resource "aws_eip" "nat" {
  tags = {
    Name = "${local.name}-nat-ip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[var.ngw_public_subnet_index].id
  tags = {
    Name = "${local.name}-ngw"
  }
}