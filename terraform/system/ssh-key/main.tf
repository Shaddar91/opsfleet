resource "aws_key_pair" "bastion" {
  key_name   = "${var.environment}-bastion"
  public_key = var.bastion_public_key
}
