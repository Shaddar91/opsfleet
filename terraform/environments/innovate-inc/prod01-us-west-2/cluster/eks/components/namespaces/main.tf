#prod01-usw2 namespaces the component releases and apps install into, one manifest per entry from files/templates/namespace.yaml.tpl.

resource "kubectl_manifest" "namespace" {
  for_each = var.namespaces

  yaml_body = templatefile("${path.module}/files/templates/namespace.yaml", {
    NAME        = each.key
    LABELS      = each.value.labels
    ANNOTATIONS = each.value.annotations
  })
  wait = true
}
