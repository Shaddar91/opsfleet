module "ec2_sg" {
  source      = "../../sg"
  name        = "${var.environment}-${var.application}"
  environment = var.environment
  vpc_id      = var.vpc_id
  rules_cidr  = var.rules_cidr
  rules_sg    = var.rules_sg
  application = var.application
}

#EKS creates and owns the cluster SG, so its tags go on through aws_ec2_tag.
resource "aws_ec2_tag" "cluster_sg" {
  for_each    = local.cluster_security_group_tags
  resource_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  key         = each.key
  value       = each.value
}
