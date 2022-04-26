resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.lambda_alarm_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  timeout = 5
  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  runtime = "nodejs12.x"

  environment {
    variables = {
      LOG_GROUP = var.cloudtrail_log_group_name,
      TOPIC_ARN=var.aws_sns_topic_arn,
      OFFSET=400000
    }
  }
}

resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_notification.arn
}

data "archive_file" "lambda_zip" {
  type = "zip"

  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_cloudwatch_log_group" "alarm_lambda" {
  name = "/aws/lambda/${var.lambda_alarm_name}"
  retention_in_days = 14
}