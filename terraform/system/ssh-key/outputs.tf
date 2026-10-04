output "key_name" {
  description = "Name of the bastion key pair, the same in every region"
  value       = module.bastion_key.key_name
}

output "key_pair_id" {
  description = "Id of the bastion key pair in the system region"
  value       = module.bastion_key.key_pair_ids[var.region]
}

output "fingerprint" {
  description = "Fingerprint AWS computed for the imported key"
  value       = module.bastion_key.fingerprints[var.region]
}
