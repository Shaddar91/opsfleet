resource "aws_instance" "main" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  source_dest_check           = true
  subnet_id                   = var.subnet
  associate_public_ip_address = var.public_ip
  user_data                   = var.user_data
  user_data_replace_on_change = true
  credit_specification {
    cpu_credits = "standard"
  }
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = "stop"
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "${var.environment}-${var.application}"
  }

  vpc_security_group_ids = [
    var.sg_list
  ]


  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = var.size
  }

  volume_tags = {
    Name        = "${var.environment}-${var.application}-volume"
    Application = var.application
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
