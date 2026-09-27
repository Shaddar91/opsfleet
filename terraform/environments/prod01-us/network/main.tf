#prod01-us network: dedicated VPC over three AZs with its own NAT, load-balancer and Karpenter subnet tags, and a Graviton bastion.

locals {
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

module "network" {
  source = "../../../modules/network/network-1.4.1"

  application = var.application
  environment = var.environment
  region      = var.region
  vpc_cidr    = var.vpc_cidr

  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  bastion_subnets  = local.bastion_subnets
  internal_subnets = local.internal_subnets

  create_nat_gateway     = true
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_s3_endpoint     = true
  enable_tgw_attachment  = false

  instance_type = var.bastion_instance_type
  bastion_ami   = data.aws_ssm_parameter.bastion_ami.insecure_value
  ssh_key       = local.ssh_key_name
  rules_cidr    = local.bastion_rules

  bastion_iam_instance_profile = module.bastion_role.instance_profile[0].name
  bastion_user_data = templatefile("${path.module}/files/setup_script.sh", {
    ansible_bucket = local.ansible_bucket_name
    roles_key      = aws_s3_object.bastion_roles.key
    playbook_key   = aws_s3_object.bastion_playbook.key
    aws_region     = var.region
    ansible_rev    = sha256(join("", [data.archive_file.bastion_roles.output_sha256, filesha256(local.bastion_playbook)]))
  })
}
