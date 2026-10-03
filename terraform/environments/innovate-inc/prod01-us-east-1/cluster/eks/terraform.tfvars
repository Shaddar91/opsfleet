application     = "eks"
cluster_name    = "prod01-us-eks"
cluster_version = "1.36"
addon_versions = {
  vpc-cni                               = "v1.23.1-eksbuild.1"
  kube-proxy                            = "v1.36.0-eksbuild.25"
  eks-pod-identity-agent                = "v1.4.0-eksbuild.2"
  coredns                               = "v1.14.6-eksbuild.4"
  aws-secrets-store-csi-driver-provider = "v3.1.4-eksbuild.1"
}
admin_principal_arns = []
