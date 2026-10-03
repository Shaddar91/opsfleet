variable "environment" {
  type    = string
  default = "prod01-usw2"
}

variable "github_owner" {
  type = string
}

variable "repos" {
  type    = list(string)
  default = ["of-api", "of-helm"]
}
