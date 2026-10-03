module "ec2" {
  count     = length(var.bastion_subnets) > 0 ? 1 : 0
  source    = "../../ec2/ec2-bastion-1.0.1/"
  public_ip = true

  application          = "bastion"
  environment          = var.environment
  instance_type        = var.instance_type
  subnet               = aws_subnet.bastion[0].id
  sg_list              = module.ec2_sg[0].sg.id
  size                 = var.bastion_volume_size
  ami                  = var.bastion_ami
  user_data            = var.bastion_user_data
  iam_instance_profile = var.bastion_iam_instance_profile
  key_name             = var.ssh_key
  spot                 = var.bastion_spot
}

module "ec2_sg" {
  count       = length(var.bastion_subnets) > 0 ? 1 : 0
  source      = "../../sg/"
  name        = "${var.environment}-${var.application}"
  environment = var.environment
  vpc_id      = aws_vpc.main.id
  rules_cidr  = var.rules_cidr
  application = var.application
}
