argocd_namespace          = "argocd"
argocd_chart_repository   = "https://argoproj.github.io/argo-helm"
argocd_apps_chart_version = "2.0.6"

applications = {}

projects = {
  opsfleet = {
    description = "opsfleet applications, deployed from the of-helm repository"
    destinations = [
      { server = "https://kubernetes.default.svc", namespace = "argocd" },
      { server = "https://kubernetes.default.svc", namespace = "of" },
      { server = "https://kubernetes.default.svc", namespace = "of-api" },
      { server = "https://kubernetes.default.svc", namespace = "of-load" },
    ]
    finalizers = ["resources-finalizer.argocd.argoproj.io"]
  }
}
