output "secret_names" {
  description = "Secrets Manager name per tree path"
  value       = { for path, m in module.file : path => m.name }
}
