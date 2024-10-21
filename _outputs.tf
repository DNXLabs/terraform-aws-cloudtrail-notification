output "lambda_arn" {
  description = "The ARN from lambda custom message"
  value       = aws_lambda_function.lambda[*].arn
}

output "alarm_sns_topic" {
  value       = aws_sns_topic.alarms[0].arn # Output the ARN of the SNS topic created in the module
  description = "SNS Topic ARN for CloudTrail Alarms"
}