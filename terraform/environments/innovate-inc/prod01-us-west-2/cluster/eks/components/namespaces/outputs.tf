output "namespace_names" {
  description = "Names of the namespaces this stack created"
  value       = [for ns in kubectl_manifest.namespace : ns.name]
}
