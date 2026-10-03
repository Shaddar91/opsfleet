#Argo CD configuration, applied once Argo CD runs: the of-helm repository credential, then the AppProjects and Applications through argocd-apps.

resource "kubernetes_secret_v1" "helm_repo" {
  metadata {
    name      = "helm-repo"
    namespace = var.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = local.helm_repo_url
    username = var.helm_repo_credentials.username
    password = var.helm_repo_credentials.password
  }
}

resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = var.argocd_chart_repository
  chart      = "argocd-apps"
  version    = var.argocd_apps_chart_version
  namespace  = var.argocd_namespace
  values = [templatefile("${path.module}/files/values/argocd-apps.yaml", {
    APPLICATIONS = local.applications
    PROJECTS     = local.projects
  })]

  depends_on = [kubernetes_secret_v1.helm_repo]
}
