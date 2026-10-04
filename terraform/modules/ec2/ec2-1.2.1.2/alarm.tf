module "cloudwatch_alarm" {
  source              = "../../cloudwatch-1.0/alarms-merged"
  filter              = false
  metric_name         = "StatusCheckFailed_System"
  alarm_name          = "${var.environment}-${var.application}-ec2-system-status-failed-alarm"
  namespace           = "AWS/EC2"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [var.sns == null ? "" : var.sns, "arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]
  dimensions = {
    InstanceId : aws_instance.main.id
  }
}

module "cloudwatch_alarm_cpu" {
  source              = "../../cloudwatch-1.0/alarms-merged"
  filter              = false
  metric_name         = "CPUUtilization"
  alarm_name          = "${var.environment}-${var.application}-ec2-cpu-high-alarm"
  namespace           = "AWS/EC2"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  # evaluation_periods  = "2"  # For 2 periods of 60 seconds each
  period = "60"
  # statistic           = "Average"
  threshold     = "80"
  alarm_actions = [var.sns == null ? "" : var.sns]
  dimensions = {
    InstanceId = aws_instance.main.id
  }
}


resource "aws_sns_topic" "sns_alarm_cpu" {
  name = "HichCPU"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  for_each = toset(var.mails)

  topic_arn = aws_sns_topic.sns_alarm_cpu.arn
  protocol  = "email"
  endpoint  = each.value
}