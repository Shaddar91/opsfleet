argocd_namespace          = "argocd"
argocd_chart_repository   = "https://argoproj.github.io/argo-helm"
argocd_apps_chart_version = "2.0.6"

applications = {
  "of-api" = {
    project = "opsfleet"
    source = {
      path           = "charts/of-api"
      targetRevision = "master"
      helm = {
        valueFiles = ["values.yaml", "values-opsfleet.yaml", "values-graviton.yaml"]
      }
    }
    destination = {
      server    = "https://kubernetes.default.svc"
      namespace = "of"
    }
    syncPolicy = {
      automated = {
        prune    = true
        selfHeal = true
      }
      syncOptions = ["CreateNamespace=true"]
    }
  }
}

projects = {
  opsfleet = {
    description = "opsfleet applications, deployed from the of-helm repository"
    destinations = [
      { server = "https://kubernetes.default.svc", namespace = "argocd" },
      { server = "https://kubernetes.default.svc", namespace = "of" },
      { server = "https://kubernetes.default.svc", namespace = "example-api" },
      { server = "https://kubernetes.default.svc", namespace = "of-load" },
    ]
    finalizers = ["resources-finalizer.argocd.argoproj.io"]
  }
}
