# lambda
variable "lambda_function_name" {
  default = "lambda_backend_api"
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "eric_milan_dev_prod" {
  provider          = aws.prod
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
  provider = aws.prod
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
  provider    = aws.prod
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  provider   = aws.prod
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# api-gateway
resource "aws_cloudwatch_log_group" "stage_eric_milan_dev_prod" {
  provider          = aws.prod
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.eric_milan_dev_prod.id}/${var.stage_name}"
  retention_in_days = 14
  # ... potentially other configuration ...
}

# metric alarms
resource "aws_cloudwatch_metric_alarm" "lambda_error" {
  alarm_name                = "terraform-lambda-error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 80
  alarm_description         = "This metric monitors lambda function errors"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name                = "terraform-lambda-throttles"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "Throttles"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 80
  alarm_description         = "This metric monitors lambda function Throttles metric"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_latency" {
  alarm_name                = "terraform-api-gateway-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "Latency"
  namespace                 = "AWS/ApiGateway"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors api gateway latency metric"
  insufficient_data_actions = []
}
