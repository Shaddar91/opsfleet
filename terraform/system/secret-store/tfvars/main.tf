#Secrets Manager containers for the git-ignored secrets.auto.tfvars files the region scripts need, one per file named opsfleet-<tree path>; tf-secrets.sh writes and reads the values.

module "file" {
  for_each = toset(var.secrets_files)
  source   = "../../../modules/secrets-manager/container-1.0"

  name        = "opsfleet-${each.value}"
  description = "Content of ${each.value}, written by tf-secrets.sh push"
}
