output "key_name" {
  description = "Name of the bastion key pair"
  value       = aws_key_pair.bastion.key_name
}

output "key_pair_id" {
  description = "Id of the bastion key pair"
  value       = aws_key_pair.bastion.key_pair_id
}

output "fingerprint" {
  description = "Fingerprint AWS computed for the imported key"
  value       = aws_key_pair.bastion.fingerprint
}
