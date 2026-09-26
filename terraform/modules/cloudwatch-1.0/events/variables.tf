variable "pattern" {
  default = null
}
variable "schedule" {
  default = null
}
variable "pattern_or_schedule" {
  type = string
}
variable "rule_name" {
  type = string
}
variable "targets" {
  type = list
}
variable "input" {
  type = string
  default = ""
}
variable "lambda" {
    type = string
    default = null
}
variable "role_arn" {
  type = string
  default = null
}