#EKS cluster, managed node group and Karpenter node roles through iam/role; one role ARN per access entry.

module "cluster_role" {
  source = "../../../../../modules/iam/role"

  name               = "${var.cluster_name}-cluster"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume.json
  policy_list        = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"]
}

module "node_group_role" {
  source           = "../../../../../modules/iam/role"
  instance_profile = false

  name               = "${var.cluster_name}-node-group"
  assume_role_policy = data.aws_iam_policy_document.node_group_assume.json
  policy_list = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

module "karpenter_node_role" {
  source           = "../../../../../modules/iam/role"
  instance_profile = false

  name               = "${var.cluster_name}-karpenter-node"
  assume_role_policy = data.aws_iam_policy_document.karpenter_node_assume.json
  policy_list = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}
