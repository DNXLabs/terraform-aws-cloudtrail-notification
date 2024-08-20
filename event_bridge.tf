resource "aws_cloudwatch_event_rule" "alarm_notification" {
  count       = length(var.endpoints) > 0 ? 1 : 0
  name        = "cloudtrail_alarm_custom_notifications"
  description = "Will be notified with a custom message when any alarm is performed"

  event_pattern = <<PATTERN
  {
    "source": [
        "aws.cloudwatch"
    ],
    "detail-type": [
        "CloudWatch Alarm State Change"
    ],
    "detail": {
        "state": {
            "value": [
                "ALARM"
            ]
        }
    }
  }
  PATTERN
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count     = length(var.endpoints) > 0 ? 1 : 0
  rule      = aws_cloudwatch_event_rule.alarm_notification[0].name
  target_id = "NotifyLambda"
  arn       = var.alarm_protocol == "email" ? aws_lambda_function.lambda[0].arn : aws_sns_topic.alarms[0].arn
}
