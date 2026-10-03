locals {
  vpc_id           = data.terraform_remote_state.network.outputs.vpc_id
  internal_subnets = data.terraform_remote_state.network.outputs.internal_subnets
}
