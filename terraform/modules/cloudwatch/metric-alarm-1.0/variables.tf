variable "alarm_name" {
  description = "Alarm name, unique in the region"
  type        = string
}

variable "alarm_description" {
  description = "What the alarm means and what reacts to it"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Metric namespace, such as AWS/GlobalAccelerator"
  type        = string
}

variable "metric_name" {
  description = "Metric name inside the namespace"
  type        = string
}

variable "dimensions" {
  description = "Dimension name to value; must match a combination the service publishes"
  type        = map(string)
  default     = null
}

variable "statistic" {
  description = "Statistic per period: Minimum, Maximum, Average, Sum or SampleCount"
  type        = string
}

variable "period" {
  description = "Seconds per evaluation period"
  type        = number
  default     = 60
}

variable "evaluation_periods" {
  description = "Periods looked at for each evaluation"
  type        = number
}

variable "datapoints_to_alarm" {
  description = "Breaching periods out of evaluation_periods that put the alarm in ALARM; null means all of them"
  type        = number
  default     = null
}

variable "comparison_operator" {
  description = "How the statistic is compared to the threshold, such as LessThanThreshold"
  type        = string
}

variable "threshold" {
  description = "Value the statistic is compared to"
  type        = number
}

variable "treat_missing_data" {
  description = "How a period without data counts: missing, ignore, breaching or notBreaching"
  type        = string
  default     = "missing"
}

variable "alarm_actions" {
  description = "ARNs invoked when the alarm enters ALARM"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "ARNs invoked when the alarm returns to OK"
  type        = list(string)
  default     = []
}
