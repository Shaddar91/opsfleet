#of-launch host: one instance on a private subnet of the prod01-us VPC, reached through the edge ALB.

module "of_launch_01" {
  source    = "../../../../modules/ec2/ec2-1.2.1.2"
  public_ip = false

  application           = "${var.application}-01"
  ami                   = var.ami
  instance_type         = var.instance_type
  environment           = var.environment
  subnet                = local.private_subnets[0]
  sg_list               = module.of_launch_sg.sg.id
  size                  = var.disk_size
  ansible_bucket_name   = local.ansible_bucket_name
  upload_location       = local.ansible_bucket_name
  ansible_playbook_name = var.ansible_playbook
  s3_file_name          = "playbooks/${var.ansible_playbook}"
  template_vars         = local.of_launch_template_vars
  user_data = templatefile("${path.module}/files/of-launch-01.sh", {
    ANSIBLE_BUCKET   = local.ansible_bucket_name
    PLAYBOOK_NAME    = var.ansible_playbook
    AWS_REGION       = var.region
    CODEDEPLOY_APP   = module.codedeploy.app.name
    DEPLOYMENT_GROUP = module.codedeploy.deployment_group.deployment_group_name
  })
  key_name           = local.ssh_key_name
  mails              = var.mails
  metadata_hop_limit = 2
}

module "of_launch_sg" {
  source = "../../../../modules/sg"

  name        = local.name
  application = var.application
  environment = var.environment
  vpc_id      = local.vpc_id
  rules_cidr  = local.of_launch_rule_cidr
  rules_sg = [
    { type = "ingress", from_port = 22, to_port = 22, protocol = "tcp", source_sg = local.bastion_sg_id },
    { type = "ingress", from_port = 80, to_port = 80, protocol = "tcp", source_sg = local.bastion_sg_id },
    { type = "ingress", from_port = 443, to_port = 443, protocol = "tcp", source_sg = local.bastion_sg_id },
    { type = "ingress", from_port = 8080, to_port = 8080, protocol = "tcp", source_sg = local.bastion_sg_id },
    { type = "ingress", from_port = 80, to_port = 80, protocol = "tcp", source_sg = local.alb_sg_id },
    { type = "ingress", from_port = 443, to_port = 443, protocol = "tcp", source_sg = local.alb_sg_id },
    { type = "ingress", from_port = 8080, to_port = 8080, protocol = "tcp", source_sg = local.alb_sg_id },
  ]
}
