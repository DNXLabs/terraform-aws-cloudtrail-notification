# terraform-aws-template

[![Lint Status](https://github.com/DNXLabs/terraform-aws-template/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-template/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-template)](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE)

<!--- BEGIN_TF_DOCS --->

# AWS CloudTrail Notification Terraform Module

Terraform module to provision an CloudTrail with a custom notification.

## Introduction
- When you get an alarm, you want enough information to decide whether it needs immediate attention or not. You also want to customize the notification message to operational needs. The **CloudWatch Logs Customize Alarms** is a Lambda function that helps in reading the logs from CloudWatch Logs during an alarm and send a customized email through SNS.

## Flow of Events

![Flow of events](./assets/cloudtrail_notification.jpeg)

## Prerequisites

- [CloudWatch log group](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Working-with-log-groups-and-streams.html) Logs has a Log group with a metric filter.
* [CloudWatch Alarm](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Working-with-log-groups-and-streams.html)  is created to trigger when that metric exceeds a threshold.
- [SNS](https://docs.aws.amazon.com/sns/latest/dg/sns-create-topic.html) subscription topic responsible to send the custom notification.

## Triggers
* The Lambda function is triggered on a EventBridge event.
* You need to provide the SNS topic.




## Usage

This example:

```terraform
locals {
  log_group_name = "LogGroupName"
  sns_topic_arn  = "arn:aws:sns:us-east-2:444455556666:MyTopic"
}

module "cloudtrail_custom_alarms" {
  source                       = "git::https://github.com/DNXLabs/terraform-aws-cloudtrail-notification.git?ref=4.0.0"
  cloudtrail_log_group_name    = local.log_group_name
  alarm_notification_sns_topic = local.sns_topic_arn
  alarm_mode                   = "light"  # or "full"
  lambda_timeout               = 5
  kms_key                      = ""  # Optional: KMS key ARN for SNS encryption
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 3.74.1 |



## Resources

| Name | Type |
|------|------|
| [aws_lambda_function.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_cloudwatch_log_group.alarm_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy.lambda_cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_cloudwatch_event_rule.alarm_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy_document.lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file) | data source |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lambda_name | The name for the lambda resource for the custom message.  | `string` | `lambda_alarm_notification` | no |
| cloudtrail_log_group_name | The name of the loggroup that has all Cloudtrail Logs that will be used to get information to create custom message. | `string` | n/a | yes |
| alarm_notification_sns_topic | The ARN of SNS Topic that will be responsible to send notification | `string` | `""` | no |
| lambda_timeout | Set lambda Timeout. | `number` | `3` | no |
| alarm_mode | Version of alarms to use. 'light' or 'full' available | `string` | `"light"` | no |
| kms_key | KMS key ARN used to encrypt SNS topic | `string` | `""` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda_arn | The Lambda ARN. |


<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. See [LICENSE](https://github.com/idealo/terraform-aws-opensearch/blob/main/LICENSE) for full details.