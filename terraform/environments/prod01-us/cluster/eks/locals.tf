locals {
  #Graviton groups are added the same way, with ami_type AL2023_ARM_64_STANDARD and Graviton instance types.
  node_groups = [
    {
      name           = "system"
      subnets        = local.private_subnets
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m7i.large"]
      scaling        = { desired = 2, min = 2, max = 3 }
      labels         = { role = "system" }
    },
  ]

  addons = {
    vpc-cni                = { before_compute = true }
    kube-proxy             = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
    coredns                = {}
  }
}
