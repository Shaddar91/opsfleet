resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-${var.application}-eks"
  role_arn = module.cluster_role.role_arn
  version  = var.cluster_verison
  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    subnet_ids              = var.cluster_subnet_ids
  }

  depends_on = [
    module.cluster_role,
  ]
}
