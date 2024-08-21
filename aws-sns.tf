# --------------------------------------------------------------------------------------------------
# The SNS topic to which CloudWatch alarms send events.
# --------------------------------------------------------------------------------------------------
resource "aws_sns_topic" "alarms" {
  count             = length(var.endpoints) > 0 ? 1 : 0
  name              = var.sns_topic_name
  kms_master_key_id = var.kms_key #aws_kms_key.sns[0].id # default key does not allow cloudwatch alarms to publish
  tags              = var.tags
}


resource "aws_sns_topic_policy" "alarms" {
  count  = length(var.endpoints) > 0 ? 1 : 0
  arn    = aws_sns_topic.alarms[0].arn
  policy = data.aws_iam_policy_document.alarms_policy[0].json
}

data "aws_iam_policy_document" "alarms_policy" {
  count     = length(var.endpoints) > 0 ? 1 : 0
  policy_id = "allow-org-accounts"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [aws_sns_topic.alarms[0].arn]
    sid       = "allow-org-accounts"
  }
}

resource "aws_sns_topic_subscription" "cloudtrail_custom_alarm_email" {
  for_each  = toset(var.endpoints)
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = var.alarm_protocol
  endpoint  = each.value
}
