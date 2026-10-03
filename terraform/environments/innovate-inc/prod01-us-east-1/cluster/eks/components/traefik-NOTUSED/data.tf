data "kubectl_file_documents" "crds" {
  for_each = fileset("${path.module}/files/crds", "*.yaml")

  content = file("${path.module}/files/crds/${each.value}")
}
