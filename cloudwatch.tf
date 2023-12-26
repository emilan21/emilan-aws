# lambda
variable "lambda_function_name" {
  default = "lambda_backend_api"
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "eric_milan_dev_prod" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# api-gateway
resource "aws_cloudwatch_log_group" "stage_eric_milan_dev_prod" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.eric_milan_dev_prod.id}/${var.stage_name}"
  retention_in_days = 14
  # ... potentially other configuration ...
}

# metric alarms
resource "aws_cloudwatch_metric_alarm" "lambda_error" {
  alarm_name                = "terraform-lambda-error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 10
  alarm_description         = "This metric monitors lambda function errors"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.cloudwatch_metric_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_metric_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name                = "terraform-lambda-throttles"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Throttles"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 5
  alarm_description         = "This metric monitors lambda function Throttles metric"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.cloudwatch_metric_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_metric_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_5xxerror" {
  alarm_name                = "terraform-api-gateway-5xxerror"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "5XXError"
  namespace                 = "AWS/ApiGateway"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 20
  alarm_description         = "This metric monitors api gateway 5XXError metric"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.cloudwatch_metric_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_metric_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_4xxerror" {
  alarm_name                = "terraform-api-gateway-4xxerror"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "4XXError"
  namespace                 = "AWS/ApiGateway"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 20
  alarm_description         = "This metric monitors api gateway 4XXError metric"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.cloudwatch_metric_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_metric_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_count" {
  alarm_name                = "terraform-api-gateway-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Count"
  namespace                 = "AWS/ApiGateway"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 20
  alarm_description         = "This metric monitors api gateway count metric"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.cloudwatch_metric_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_metric_alarms.arn]
}
