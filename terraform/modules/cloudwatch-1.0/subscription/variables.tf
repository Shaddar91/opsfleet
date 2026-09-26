variable "filter_name" {
    type = string
}
variable "log_group" {
  type    = map(string)
  default = {}
}
variable "lambda" {
  type    = map(string)
  default = {}
}

variable "pattern" {
    type = string
}