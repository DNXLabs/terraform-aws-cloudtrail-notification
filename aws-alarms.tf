locals {
  resource_tags = merge(var.tags, { "Automation" = "Terraform" })
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "UnauthorizedAPICalls"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "UnauthorizedAPICalls"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "UnauthorizedAPICalls"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.unauthorized_api_calls[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "10"
  alarm_description         = "Monitoring unauthorized API calls will help reveal application errors and may reduce time to detect malicious activity."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "no_mfa_console_signin_assumed_role" {
  count = var.alarm_mode == "full" || var.alarm_mode == "light" ? 1 : 0

  name           = "NoMFAConsoleSigninAssume"
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "NoMFAConsoleSigninAssume"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "no_mfa_console_signin_assumed_role" {
  count = var.alarm_mode == "full" || var.alarm_mode == "light" ? 1 : 0

  alarm_name                = "NoMFAConsoleSigninAssume"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.no_mfa_console_signin_assumed_role[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring for single-factor console logins will increase visibility into accounts that are not protected by MFA."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}
resource "aws_cloudwatch_log_metric_filter" "no_mfa_console_signin_no_assumed_role" {
  count = var.alarm_mode == "full" || var.alarm_mode == "light" ? 1 : 0

  name           = "NoMFAConsoleSignin"
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") && ($.userIdentity.arn != \"*assumed-role*\") }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "NoMFAConsoleSignin"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "no_mfa_console_signin" {
  count = var.alarm_mode == "full" || var.alarm_mode == "light" ? 1 : 0

  alarm_name                = "NoMFAConsoleSignin"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.no_mfa_console_signin_no_assumed_role[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring for single-factor console logins will increase visibility into accounts that are not protected by MFA."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "root_usage" {
  count = var.alarm_mode == "full" || var.alarm_mode == "light" ? 1 : 0

  name           = "RootUsage"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "RootUsage"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_usage" {
  count = var.alarm_mode == "full" || var.alarm_mode == "light" ? 1 : 0

  alarm_name                = "RootUsage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.root_usage[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring for root account logins will provide visibility into the use of a fully privileged account and an opportunity to reduce the use of it."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "iam_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "IAMChanges"
  pattern        = "{($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "IAMChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "IAMChanges"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.iam_changes[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring changes to IAM policies will help ensure authentication and authorization controls remain intact."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "cloudtrail_cfg_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "CloudTrailCfgChanges"
  pattern        = "{ ($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "CloudTrailCfgChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_cfg_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "CloudTrailCfgChanges"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.cloudtrail_cfg_changes[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring changes to CloudTrail's configuration will help ensure sustained visibility to activities performed in the AWS account."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "console_signin_failures" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "ConsoleSigninFailures"
  pattern        = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "ConsoleSigninFailures"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_signin_failures" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "ConsoleSigninFailures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.console_signin_failures[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring failed console logins may decrease lead time to detect an attempt to brute force a credential, which may provide an indicator, such as source IP, that can be used in other event correlation."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "disable_or_delete_cmk" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "DisableOrDeleteCMK"
  pattern        = "{ ($.eventSource = kms.amazonaws.com) && (($.eventName = DisableKey) || ($.eventName = ScheduleKeyDeletion)) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "DisableOrDeleteCMK"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "disable_or_delete_cmk" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "DisableOrDeleteCMK"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.disable_or_delete_cmk[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Data encrypted with disabled or deleted keys will no longer be accessible."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "s3_bucket_policy_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "S3BucketPolicyChanges"
  pattern        = "{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "S3BucketPolicyChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_bucket_policy_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "S3BucketPolicyChanges"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.s3_bucket_policy_changes[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring changes to S3 bucket policies may reduce time to detect and correct permissive policies on sensitive S3 buckets."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "aws_config_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "AWSConfigChanges"
  pattern        = "{ ($.eventSource = config.amazonaws.com) && (($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel)||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder)) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "AWSConfigChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_config_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "AWSConfigChanges"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.aws_config_changes[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring changes to AWS Config configuration will help ensure sustained visibility of configuration items within the AWS account."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "security_group_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "SecurityGroupChanges"
  pattern        = "{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup)}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "SecurityGroupChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "security_group_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "SecurityGroupChanges"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.security_group_changes[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring changes to security group will help ensure that resources and services are not unintentionally exposed."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "nacl_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "NACLChanges"
  pattern        = "{ ($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "NACLChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "nacl_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "NACLChanges"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.nacl_changes[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring changes to NACLs will help ensure that AWS resources and services are not unintentionally exposed."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "network_gw_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "NetworkGWChanges"
  pattern        = "{ ($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "NetworkGWChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "network_gw_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "NetworkGWChanges"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.network_gw_changes[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring changes to network gateways will help ensure that all ingress/egress traffic traverses the VPC border via a controlled path."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "route_table_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "RouteTableChanges"
  pattern        = "{ ($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "RouteTableChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "route_table_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "RouteTableChanges"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.route_table_changes[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring changes to route tables will help ensure that all VPC traffic flows through an expected path."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_metric_filter" "vpc_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  name           = "VPCChanges"
  pattern        = "{ ($.eventName = CreateVpc) || ($.eventName = DeleteVpc) || ($.eventName = ModifyVpcAttribute) || ($.eventName = AcceptVpcPeeringConnection) || ($.eventName = CreateVpcPeeringConnection) || ($.eventName = DeleteVpcPeeringConnection) || ($.eventName = RejectVpcPeeringConnection) || ($.eventName = AttachClassicLinkVpc) || ($.eventName = DetachClassicLinkVpc) || ($.eventName = DisableVpcClassicLink) || ($.eventName = EnableVpcClassicLink) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "VPCChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "vpc_changes" {
  count = var.alarm_mode == "full" ? 1 : 0

  alarm_name                = "VPCChanges"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.vpc_changes[0].id
  namespace                 = "CloudTrailMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring changes to VPC will help ensure that all VPC traffic flows through an expected path."
  alarm_actions             = try([aws_sns_topic.alarms[0].arn], [])
  ok_actions                = try([aws_sns_topic.alarms[0].arn], [])
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []

  tags = local.resource_tags
}