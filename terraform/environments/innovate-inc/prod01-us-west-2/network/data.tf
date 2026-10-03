data "aws_availability_zones" "available" {
  state            = "available"
  exclude_zone_ids = []

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

data "aws_ec2_instance_type" "bastion" {
  instance_type = var.bastion_instance_type
}

data "aws_ssm_parameter" "bastion_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-${local.bastion_arch}"
}

data "aws_partition" "current" {}

data "archive_file" "bastion_roles" {
  type             = "tar.gz"
  source_dir       = "${path.module}/files/ansible/roles"
  output_path      = "${path.module}/.terraform/bastion-roles.tar.gz"
  output_file_mode = "0666"
}
