#MySQL data on its own volume, so it survives replacing the instance.

resource "aws_ebs_volume" "mysql_data" {
  availability_zone = data.aws_subnet.of_launch.availability_zone
  size              = var.mysql_volume_size
  type              = "gp3"
  encrypted         = true

  tags = {
    Name        = "${local.name}-mysql-data"
    Environment = var.environment
    Application = var.application
  }
}

resource "aws_volume_attachment" "mysql_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.mysql_data.id
  instance_id = module.of_launch_01.ec2_id

  #never detach a mounted data volume on destroy; terminating the instance releases it
  skip_destroy = true
}
