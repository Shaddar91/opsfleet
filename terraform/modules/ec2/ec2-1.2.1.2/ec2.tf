resource "aws_instance" "main" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  source_dest_check           = true
  subnet_id                   = var.subnet
  associate_public_ip_address = var.public_ip
  user_data                   = base64encode(var.user_data)
  credit_specification {
    cpu_credits = "standard"
  }
  iam_instance_profile                 = aws_iam_instance_profile.ec2_profile.name
  instance_initiated_shutdown_behavior = "stop"
  tags = merge(
    {
      Name        = "${var.environment}-${var.application}"
      Environment = var.environment
      Application = var.application
    },
    var.tags
  )

  vpc_security_group_ids = [
    var.sg_list
  ]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = var.metadata_hop_limit
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = var.size
  }

  volume_tags = {
    Name        = "${var.environment}-${var.application}-volume"
    Application = var.application
  }
}