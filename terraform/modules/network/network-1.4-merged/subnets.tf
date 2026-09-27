resource "aws_subnet" "bastion" {
  count             = length(var.bastion_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.bastion_subnets[count.index].cidr_block
  availability_zone = var.bastion_subnets[count.index].availability_zone

  tags = merge({
    Name = "${local.name}-bastion-subnet-${count.index + 1}"
  }, try(var.bastion_subnets[count.index].additional_tags, {}))
}

resource "aws_route_table_association" "bastion" {
  count          = length(var.bastion_subnets)
  subnet_id      = aws_subnet.bastion[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block              = var.public_subnets[count.index].cidr_block
  availability_zone       = var.public_subnets[count.index].availability_zone

  tags = merge({
    Name = "${local.name}-public-subnet-${count.index + 1}"
  }, try(var.public_subnets[count.index].additional_tags, {}))
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index].cidr_block
  availability_zone = var.private_subnets[count.index].availability_zone

  tags = merge({
    Name = "${local.name}-private-subnet-${count.index + 1}"
  }, try(var.private_subnets[count.index].additional_tags, {}))
}

resource "aws_route_table_association" "nat" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.nat.id
}

resource "aws_subnet" "internal" {
  count             = length(var.internal_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.internal_subnets[count.index].cidr_block
  availability_zone = var.internal_subnets[count.index].availability_zone

  tags = merge({
    Name = "${local.name}-internal-subnet-${count.index + 1}"
  }, try(var.internal_subnets[count.index].additional_tags, {}))
}

resource "aws_route_table_association" "internal" {
  count          = length(var.internal_subnets)
  subnet_id      = aws_subnet.internal[count.index].id
  route_table_id = aws_route_table.internal.id
}

resource "aws_subnet" "lambda" {
  count             = length(var.lambda_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.lambda_subnets[count.index].cidr_block
  availability_zone = var.lambda_subnets[count.index].availability_zone

  tags = merge({
    Name = "${local.name}-lambda-subnet-${count.index + 1}"
  }, try(var.lambda_subnets[count.index].additional_tags, {}))
}

resource "aws_route_table_association" "lambda_nat" {
  for_each       = local.lambda_nat_subnet_keys
  subnet_id      = aws_subnet.lambda[each.value].id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table_association" "lambda_internal" {
  for_each       = local.lambda_internal_subnet_keys
  subnet_id      = aws_subnet.lambda[each.value].id
  route_table_id = aws_route_table.internal.id
}
