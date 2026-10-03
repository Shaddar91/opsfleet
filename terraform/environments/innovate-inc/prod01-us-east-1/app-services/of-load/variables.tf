variable "application" {
  type        = string
  description = "Application name; with environment it names the target group, the certificate and the Argo CD Application"
}

variable "subdomain" {
  type        = string
  description = "Label under the public zone; <subdomain>.<zone domain> is the host the edge ALB rule forwards to this service"
}

variable "container_port" {
  type        = number
  description = "Port the pods listen on; the target group, the security group rule and the chart's containerPort use it"
}

variable "health_check_path" {
  type        = string
  description = "HTTP path the target group health check requests on each pod"
}

variable "priority" {
  type        = number
  description = "Priority of the host rule on the edge ALB HTTPS listener, unique on that listener"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace the module creates and the Argo CD Application deploys into"
}

variable "architecture" {
  type        = string
  description = "Node architecture the pods run on, arm64 or amd64; picks the chart's values-<architecture>.yaml"
}

variable "argocd_namespace" {
  type        = string
  description = "Namespace Argo CD runs in, where the Application object is created"
}

variable "git_repository" {
  type        = string
  description = "Helm repository, without the owner, that holds the chart and that Argo CD watches"
}

variable "git_branch" {
  type        = string
  description = "Branch of git_repository the chart is committed to and Argo CD tracks"
}

variable "git_path" {
  type        = string
  description = "Chart folder inside git_repository, no leading or trailing slash"
}

variable "commit_author" {
  type        = string
  description = "Author name on the chart commits to git_repository; set together with commit_email"
}

variable "commit_email" {
  type        = string
  description = "Author email on the chart commits to git_repository; set together with commit_author"
}

variable "argocd_project" {
  type        = string
  description = "Argo CD AppProject the Application belongs to; defined in the argocd components stack."
}

variable "web_subdomain" {
  type        = string
  description = "Label under the public zone the frontend is served on; https://<web_subdomain>.<zone domain> is the one browser origin the stress API answers, CORS_ALLOWED_ORIGINS in the app secret"
}
