output "key_name" {
  description = "Key pair name, the same in every region"
  value       = values(aws_key_pair.main)[0].key_name
}

output "key_pair_ids" {
  description = "Key pair id by region"
  value       = { for region, key in aws_key_pair.main : region => key.key_pair_id }
}

output "fingerprints" {
  description = "Fingerprint AWS computed for the imported key, by region"
  value       = { for region, key in aws_key_pair.main : region => key.fingerprint }
}
