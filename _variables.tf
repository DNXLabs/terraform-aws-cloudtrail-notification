variable "lambda_name" {
  description = "The name of the lambda which will be notified with a custom message when any alarm is performed."
  type        = string
  default     = "lambda_alarm_notification"
}

variable "cloudtrail_log_group_name" {
  description = "The name of the loggroup that will get information from"
  type        = string
}

variable "lambda_timeout" {
  description = "Set lambda Timeout"
  type        = number
  default     = 3
}

variable "sns_topic_name" {
  description = "The name of the SNS Topic which will be notified when any alarm is performed."
  type        = string
  default     = "CISAlarmV2"
}

variable "alarm_notification_sns_topic" {
  description = "The arn of the SNS Topic which will be notified when any alarm is performed."
  type        = string
  default     = ""
}

variable "emails" {
  default = []
  type    = list(string)
}

variable "alarm_mode" {
  default     = "light"
  type        = string
  description = "Version of alarms to use. 'light' or 'full' available"
}

variable "tags" {
  description = "Specifies object tags key and value. This applies to all resources created by this module."
  type        = map(string)
  default = {
    "Terraform" = true
  }
}

variable "kms_key" {
  default     = ""
  type        = string
  description = "kms used to encrypt SNS topic"
}
