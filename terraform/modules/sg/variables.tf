variable "application" {
  type = string
}
variable "environment" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "rules_sg" {
  type    = list(any)
  default = []
}
variable "rules_cidr" {
  type    = list(any)
  default = []
}
variable "rules_self" {
  type    = list(any)
  default = []
}

variable "name" {
  default = null
  type    = string
}