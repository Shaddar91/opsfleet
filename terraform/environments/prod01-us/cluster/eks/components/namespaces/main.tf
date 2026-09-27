#prod01-us namespaces the component releases and apps install into, one manifest per entry from files/templates/namespace.yaml.tpl.

resource "kubectl_manifest" "namespace" {
  for_each = var.namespaces

  yaml_body = templatefile("${path.module}/files/templates/namespace.yaml.tpl", {
    name        = each.key
    labels      = each.value.labels
    annotations = each.value.annotations
  })
  wait = true
}
