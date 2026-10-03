#One TargetGroupBinding per ALB; targetGroupARN is immutable, so a new target group replaces the binding, and destroy waits out the controller's finalizer.

resource "kubectl_manifest" "target_group_binding" {
  for_each = local.target_group_bindings

  yaml_body = each.value
  force_new = true
  wait      = true

  depends_on = [helm_release.traefik]
}
