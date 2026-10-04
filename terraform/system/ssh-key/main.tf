module "bastion_key" {
  source     = "../../modules/ec2/key-pair-1.0"
  key_name   = "${var.environment}-bastion"
  public_key = var.bastion_public_key
  regions    = concat([var.region], var.replica_regions)
}

#the key created before the module stays in place: same key, new address
moved {
  from = aws_key_pair.bastion
  to   = module.bastion_key.aws_key_pair.main["us-east-1"]
}
