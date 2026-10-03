variable "deploy_enabled" {
  description = "DEPLOY_ENABLED on every repo: \"true\" lets the workflows' deploy jobs run on master, \"false\" keeps them build-only"
  type        = string

  validation {
    condition     = contains(["true", "false"], var.deploy_enabled)
    error_message = "deploy_enabled must be \"true\" or \"false\": the workflows compare vars.DEPLOY_ENABLED to 'true', so any other value leaves deploys off without an error."
  }
}
