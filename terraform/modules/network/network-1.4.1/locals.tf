locals {
  name = "${var.environment}-${var.application}"
  lambda_nat_subnet_keys = toset(compact([
    for i, subnet in var.lambda_subnets : subnet.route_table == "nat" ? i : ""
  ]))
  lambda_internal_subnet_keys = toset(compact([
    for i, subnet in var.lambda_subnets : subnet.route_table == "internal" ? i : ""
  ]))
  private_rt_count = var.one_nat_gateway_per_az ? length(var.public_subnets) : 1
  nat_count        = var.create_nat_gateway ? local.private_rt_count : 0
}
