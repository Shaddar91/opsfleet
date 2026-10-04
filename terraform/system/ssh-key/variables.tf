variable "bastion_public_key" {
  description = "Bastion public key as \"<type> <base64>\" with the comment stripped; export TF_VAR_bastion_public_key from the env file outside the repo"
  type        = string

  validation {
    condition     = can(regex("^(ssh-ed25519|ssh-rsa) [A-Za-z0-9+/]+=*$", var.bastion_public_key))
    error_message = "bastion_public_key must be \"ssh-ed25519 <base64>\" or \"ssh-rsa <base64>\" with the trailing user@host comment stripped."
  }
}

variable "replica_regions" {
  description = "Regions besides the system region that get the same key pair, so their instances can use it"
  type        = list(string)
}
