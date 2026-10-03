locals {
  bastion_playbook = "${path.module}/files/ansible/bastion.yml"

  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  bastion_arch = contains(data.aws_ec2_instance_type.bastion.supported_architectures, "arm64") ? "arm64" : "x86_64"

  private_subnets = [for i, az in local.azs : {
    cidr_block        = cidrsubnet(var.vpc_cidr, 2, i)
    availability_zone = az
    additional_tags = {
      "kubernetes.io/role/internal-elb" = "1"
      "karpenter.sh/discovery"          = var.cluster_name
    }
  }]
  public_subnets = [for i, az in local.azs : {
    cidr_block        = cidrsubnet(var.vpc_cidr, 6, 48 + i)
    availability_zone = az
    additional_tags   = { "kubernetes.io/role/elb" = "1" }
  }]
  bastion_subnets = [for i, az in local.azs : {
    cidr_block        = cidrsubnet(cidrsubnet(var.vpc_cidr, 6, 51), 6, i)
    availability_zone = az
    additional_tags   = {}
  }]
  internal_subnets = [for i, az in local.azs : {
    cidr_block        = cidrsubnet(var.vpc_cidr, 6, 52 + i)
    availability_zone = az
    additional_tags   = {}
  }]

  bastion_rules = concat(
    [{ type = "egress", from_port = 0, to_port = 0, protocol = "-1", cidrs = ["0.0.0.0/0"] }],
    length(var.bastion_allowed_cidrs) > 0 ? [{ type = "ingress", from_port = 22, to_port = 22, protocol = "tcp", cidrs = var.bastion_allowed_cidrs }] : []
  )
}
