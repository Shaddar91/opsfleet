data "aws_availability_zones" "available" {
  state = "available"
  #EKS rejects cluster subnets in use1-az3.
  exclude_zone_ids = ["use1-az3"]

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
