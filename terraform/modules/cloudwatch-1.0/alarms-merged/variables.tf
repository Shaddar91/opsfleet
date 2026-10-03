variable "namespace" {
  type    = string
  default = "LogMetrics"
}
variable "filter" {
  type    = bool
  default = true
}
variable "filter_name" {
  type    = string
  default = null
}
variable "log_group_name" {
  type    = string
  default = null
}
variable "pattern" {
  type    = string
  default = null
}
variable "metric_name" {
  type = string
}
variable "alarm_name" {
  type = string
}
variable "comparison_operator" {
  type = string
}
variable "alarm_actions" {
  type = list(any)
}
variable "period" {
  type    = string
  default = "60"
}
variable "dimensions" {
  type    = map(any)
  default = null
}
variable "threshold" {
  type    = string
  default = "1"
}

variable "treat_missing_data" {
  type        = string
  description = "(Optional) Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to missing."
  default     = null
}
