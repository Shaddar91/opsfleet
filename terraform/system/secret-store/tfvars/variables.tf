variable "secrets_files" {
  description = "Tree paths, relative to terraform/, of the secrets.auto.tfvars files kept in Secrets Manager as opsfleet-<path>; tf-secrets.sh reads this list"
  type        = list(string)
}
