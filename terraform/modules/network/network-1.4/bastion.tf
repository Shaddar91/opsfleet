module "ec2" {
  source              = "../../ec2/ec2-1.0/"
  application         = "bastion"
  environment         = var.environment
  instance_type       = var.instance_type
  public_ip           = true
  subnet              = aws_subnet.bastion[0].id
  sg_list             = module.ec2_sg.sg.id
  size                = "100"
  path                = "files/user_data.sh"
  ansible_bucket_name = var.ansible_bucket_name
  ami                 = var.bastion_ami
  user_data_vars = {
    bucket_name   = var.ansible_bucket_name
    playbook_name = var.bastion_playbook_name
  }
  key_name = var.ssh_key
}

module "ec2_sg" {
  source      = "../../sg/"
  name        = "${var.environment}-${var.application}"
  environment = var.environment
  vpc_id      = aws_vpc.main.id
  rules_cidr  = var.rules_cidr
  application = var.application
}
