locals {
  admin_principal_arn = data.aws_iam_session_context.runner.issuer_arn
  public_access_cidrs = ["${chomp(data.http.runner_ip.response_body)}/32"]

  #role = system is the nodeSelector of the Karpenter, Load Balancer Controller and metrics-server components
  node_groups = [
    {
      name           = "spot-arm-ng-1"
      subnets        = local.private_subnets
      capacity_type  = "SPOT"
      ami_type       = "AL2023_ARM_64_STANDARD"
      instance_types = ["t4g.large"]
      scaling        = { desired = 1, min = 1, max = 10 }
      ebs            = { size = 150, iops = 100, throughput = 125, type = "gp3", device_name = "/dev/xvda" }
      labels         = { "role" = "system", "type" = "spot-arm-1", "capacity-type" = "spot" }
      tags           = { "NodeType" = "spot-arm-1" }
    },
    {
      name           = "spot-x86-ng-1"
      subnets        = local.private_subnets
      capacity_type  = "SPOT"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.large", "t3a.large"]
      scaling        = { desired = 1, min = 1, max = 10 }
      ebs            = { size = 150, iops = 100, throughput = 125, type = "gp3", device_name = "/dev/xvda" }
      labels         = { "role" = "system", "type" = "spot-x86-1", "capacity-type" = "spot" }
      tags           = { "NodeType" = "spot-x86-1" }
    },
  ]

  addons = {
    vpc-cni                = { before_compute = true }
    kube-proxy             = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
    coredns                = { resolve_conflicts_on_update = "PRESERVE" }
    aws-secrets-store-csi-driver-provider = {
      configuration_values = file("${path.module}/files/addons/aws-secrets-store-csi-driver-provider.json")
    }
  }
}
