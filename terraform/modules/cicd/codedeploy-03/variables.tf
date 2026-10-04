data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

variable "application" {
  type = string
}

variable "compute_platform" {
  type    = string
  default = "Server"
}

variable "deployment_config_name" {
  type    = string
  default = "CodeDeployDefault.AllAtOnce"
}

variable "environment" {
  type = string
}

variable "service_role" {
  type    = string
  default = null
}

variable "buildspec" {
  type    = string
  default = "buildspec.yml"
}

variable "tag_value" {
  type = string
}

variable "asg_name" {
  type        = string
  default     = null
  description = "ASG name for auto-deployment to new instances. When set, CodeDeploy deploys last successful revision to new ASG instances."
}

variable "enable_asg_integration" {
  type        = bool
  default     = true
  description = "Enable ASG integration with CodeDeploy. When false, disables lifecycle hooks that auto-deploy to new instances. Set to false during initial setup or when app layer isn't ready."
}

variable "lifecycle_hook_enabled" {
  type        = bool
  default     = false
  description = "Enable custom lifecycle hook for deployment control. When false (default), AWS auto-manages with 30min timeout. When true, creates custom hook with configurable timeout."
}

variable "lifecycle_hook_timeout" {
  type        = number
  default     = 3600
  description = "Heartbeat timeout in seconds for lifecycle hook (default: 3600 = 1 hour). Only used when lifecycle_hook_enabled is true."
}

variable "lifecycle_hook_default_result" {
  type        = string
  default     = "ABANDON"
  description = "Default result when lifecycle hook times out. ABANDON = terminate instance, CONTINUE = let instance proceed regardless."
}

