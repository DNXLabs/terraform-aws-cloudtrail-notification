data "aws_iam_policy_document" "lambda_assume_role" {
  count = var.alarm_protocol == "email" && length(var.endpoints) > 0 ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  count              = var.alarm_protocol == "email" && length(var.endpoints) > 0 ? 1 : 0
  name               = "cloudtrail-cn-role-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[0].json
  tags               = var.tags
}

resource "aws_iam_policy" "lambda_cw" {
  count       = var.alarm_protocol == "email" && length(var.endpoints) > 0 ? 1 : 0
  name        = "cloudtrail-cn-policy-${data.aws_region.current.name}"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:DescribeAlarms",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeMetricFilters",
          "logs:FilterLogEvents"
        ],
        Resource : [aws_lambda_function.lambda[0].arn, "arn:aws:logs:*:*:*", "arn:aws:cloudwatch:*:*:*"]
        Effect : "Allow"
      },
      {
        Action : ["SNS:Publish"],
        Resource : "arn:aws:sns:*:*:*",
        Effect : "Allow"
      },
      {
        Action : ["kms:Decrypt", "kms:GenerateDataKey*"],
        Resource : "*",
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cw" {
  count      = var.alarm_protocol == "email" && length(var.endpoints) > 0 ? 1 : 0
  role       = aws_iam_role.iam_for_lambda[0].name
  policy_arn = aws_iam_policy.lambda_cw[0].arn
}
