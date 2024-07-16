# --------------------------------------------------------------------------------------------------
# The SNS topic to which CloudWatch alarms send events.
# --------------------------------------------------------------------------------------------------
resource "aws_sns_topic" "alarms" {
  count             = var.enabled ? 1 : 0
  name              = var.sns_topic_name
  kms_master_key_id = var.kms_key #aws_kms_key.sns[0].id # default key does not allow cloudwatch alarms to publish
  tags              = var.tags
}


resource "aws_sns_topic_policy" "alarms" {
  count  = var.enabled ? 1 : 0
  arn    = aws_sns_topic.alarms[0].arn
  policy = data.aws_iam_policy_document.alarms_policy[0].json
}

data "aws_iam_policy_document" "alarms_policy" {
  count     = var.enabled ? 1 : 0
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
      values   = var.alarm_account_ids
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [aws_sns_topic.alarms[0].arn]
    sid       = "allow-org-accounts"
  }
}


resource "aws_sns_topic_subscription" "cloudtrail_cutom_alarm_email" {
  #for_each = {for email in var.emails : var.emails => email}
  for_each = toset(var.emails)
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = each.value
}