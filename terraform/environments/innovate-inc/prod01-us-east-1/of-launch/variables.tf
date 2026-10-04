variable "mails" {
  type        = list(string)
  description = "Addresses subscribed to the instance alarms"
}

variable "ami" {
  type        = string
  description = "Ubuntu AMI id; its architecture matches the instance type"
}

variable "application" {
  type        = string
  description = "Application name, the suffix of every resource name"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "disk_size" {
  type        = string
  description = "Root volume size in GiB"
}

variable "mysql_volume_size" {
  type        = number
  description = "Size in GiB of the EBS volume mounted at /data/mysql"
}

variable "ansible_playbook" {
  type        = string
  description = "Playbook under files/ansible_playbook, uploaded to playbooks/ in the Ansible bucket"
}

variable "internal_domain" {
  type        = string
  description = "Name of the host in the internal zone"
}

variable "public_subdomain" {
  type        = string
  description = "Name of the dashboard in the public zone"
}

variable "alb_priority" {
  type        = number
  description = "Priority of the host rule on the edge ALB's HTTPS listener"
}

variable "gh_repo" {
  type        = string
  description = "of-launch repository name, without the owner"
}

variable "gh_branch" {
  type        = string
  description = "Branch the deploy workflow runs on, the CI role trusts, and Terraform commits to"
}

variable "of_launch_secrets" {
  type        = map(string)
  description = "Secret app settings merged last into the settings secret, such as GITHUB_TOKEN and ARGOCD_OF_TOKEN; lives only in the git-ignored secrets.auto.tfvars"
  sensitive   = true
}

variable "of_launch_seed_users" {
  type        = map(string)
  description = "Users created on first start (key=username, value=password); lives only in the git-ignored secrets.auto.tfvars"
  sensitive   = true
}
