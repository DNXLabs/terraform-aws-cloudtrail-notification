
resource "random_string" "cloudtrail_alarm_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "aws_cloudformation_stack" "cloudtrail_alarm" {
  name          = "cloudtrail-alarm-${random_string.cloudtrail_alarm_suffix.result}"
  template_body = var.alarm_mode == "full" ? file("${path.module}/cloudtrail-alarms-full.cf.json") : file("${path.module}/cloudtrail-alarms-light.cf.yml")

  parameters = {
    CloudTrailLogGroupName = var.cloudtrail_log_group_name
    AlarmNotificationTopic = try(aws_sns_topic.alarms[0].arn, var.alarm_notification_sns_topic)
  }
}
