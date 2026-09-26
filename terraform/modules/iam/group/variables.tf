variable "group" {
  type = string
}
variable "path" {
  type    = string
  default = "/"
}
variable "policy_list" {
  type    = list(any)
  default = []
}
variable "custom_policy" {
  type    = bool
  default = false
}
variable "policy_file" {
  default = null
}