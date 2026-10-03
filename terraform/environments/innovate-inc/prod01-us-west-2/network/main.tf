#prod01-usw2 network: dedicated VPC over three AZs with its own NAT, load-balancer and Karpenter subnet tags, and a Graviton Spot bastion.

module "network" {
  source                = "../../../../modules/network/network-1.4.1"
  create_nat_gateway    = true
  enable_s3_endpoint    = true
  enable_tgw_attachment = false
  enable_tgw_routing    = false

  application = var.application
  environment = var.environment
  region      = var.region
  vpc_cidr    = var.vpc_cidr

  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  bastion_subnets  = local.bastion_subnets
  internal_subnets = local.internal_subnets

  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  instance_type = var.bastion_instance_type
  bastion_spot  = var.bastion_spot
  bastion_ami   = data.aws_ssm_parameter.bastion_ami.insecure_value
  ssh_key       = local.ssh_key_name
  rules_cidr    = local.bastion_rules

  bastion_iam_instance_profile = module.bastion_role.instance_profile[0].name
  bastion_user_data = templatefile("${path.module}/files/setup_script.sh", {
    ANSIBLE_BUCKET = local.ansible_bucket_name
    ROLES_KEY      = aws_s3_object.bastion_roles.key
    PLAYBOOK_KEY   = aws_s3_object.bastion_playbook.key
    AWS_REGION     = var.region
    ANSIBLE_REV    = sha256(join("", [data.archive_file.bastion_roles.output_sha256, filesha256(local.bastion_playbook)]))
  })
}
