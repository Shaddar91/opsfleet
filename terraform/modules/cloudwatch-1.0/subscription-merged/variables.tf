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

variable "region" {
  type        = string
  description = "Region of the log group; the Lambda permission principal is logs.<region>.amazonaws.com"
}
