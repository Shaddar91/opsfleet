locals {
  name = "${var.environment}-${var.application}"
  lambda_nat_subnet_keys = toset(compact([
    for i, subnet in var.lambda_subnets : subnet.route_table == "nat" ? i : ""
  ]))
  lambda_internal_subnet_keys = toset(compact([
    for i, subnet in var.lambda_subnets : subnet.route_table == "internal" ? i : ""
  ]))
}