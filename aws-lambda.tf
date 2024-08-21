resource "aws_lambda_function" "lambda" {
  count            = length(var.endpoints) > 0 ? 1 : 0
  filename         = "${path.module}/lambda.zip"
  function_name    = var.lambda_name
  role             = aws_iam_role.iam_for_lambda[0].arn
  handler          = "index.handler"
  timeout          = var.lambda_timeout
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
  runtime          = "nodejs18.x"
  tags             = var.tags
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      LOG_GROUP = var.cloudtrail_log_group_name,
      TOPIC_ARN = aws_sns_topic.alarms[0].arn,
      OFFSET    = 180
    }
  }
}

resource "aws_lambda_permission" "default" {
  count         = length(var.endpoints) > 0 ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_notification[0].arn
}

resource "aws_cloudwatch_log_group" "alarm_lambda" {
  count             = length(var.endpoints) > 0 ? 1 : 0
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 365
  kms_key_id        = var.kms_key
  tags              = var.tags
}
