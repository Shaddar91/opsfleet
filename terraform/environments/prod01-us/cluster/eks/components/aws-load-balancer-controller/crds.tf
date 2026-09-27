#The pinned chart's crds/, vendored into files/crds/ and applied server-side before the release: Helm never upgrades chart crds/, so a chart bump swaps these files.

data "kubectl_file_documents" "crds" {
  for_each = fileset("${path.module}/files/crds", "*.yaml")

  content = file("${path.module}/files/crds/${each.value}")
}

resource "kubectl_manifest" "crds" {
  for_each = merge([for doc in data.kubectl_file_documents.crds : doc.manifests]...)

  yaml_body         = each.value
  server_side_apply = true
}
