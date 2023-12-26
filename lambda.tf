data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_permission" "get_counts_apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_visit_count_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.eric_milan_dev_prod.id}/*/${aws_api_gateway_method.get_counts_method.http_method}${aws_api_gateway_resource.get_counts.path}"
}

resource "aws_lambda_permission" "increment_counts_apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.increment_visit_count_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.eric_milan_dev_prod.id}/*/${aws_api_gateway_method.increment_counts_method.http_method}${aws_api_gateway_resource.increment_counts.path}"
}

resource "aws_lambda_permission" "delete_counts_apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_visit_count_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

data "archive_file" "get_visit_count_lambda" {
  type        = "zip"
  source_file = "../emilan-website/backend/get_visit_count.py"
  output_path = "get_visit_count_payload.zip"
}

data "archive_file" "increment_visit_count_lambda" {
  type        = "zip"
  source_file = "../emilan-website/backend/increment_visit_count.py"
  output_path = "increment_visit_count_payload.zip"
}

data "archive_file" "delete_visit_count_lambda" {
  type        = "zip"
  source_file = "../emilan-website/backend/delete_visit_count.py"
  output_path = "delete_visit_count_payload.zip"
}

resource "aws_lambda_function" "get_visit_count_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "get_visit_count_payload.zip"
  function_name = "get_visit_count"
  role          = "arn:aws:iam::518835924951:role/lambdatodynmo"
  handler       = "get_visit_count.lambda_handler"

  source_code_hash = data.archive_file.get_visit_count_lambda.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      TABLE_NAME = "visit-count-table"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.eric_milan_dev_prod,
  ]
}

resource "aws_lambda_function" "increment_visit_count_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "increment_visit_count_payload.zip"
  function_name = "increment_visit_count"
  role          = "arn:aws:iam::518835924951:role/lambdatodynmo"
  handler       = "increment_visit_count.lambda_handler"

  source_code_hash = data.archive_file.increment_visit_count_lambda.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      TABLE_NAME = "visit-count-table"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.eric_milan_dev_prod,
  ]
}

resource "aws_lambda_function" "delete_visit_count_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "delete_visit_count_payload.zip"
  function_name = "delete_visit_count"
  role          = "arn:aws:iam::518835924951:role/lambdatodynmo"
  handler       = "delete_visit_count.lambda_handler"

  source_code_hash = data.archive_file.delete_visit_count_lambda.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      TABLE_NAME = "visit-count-table"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.eric_milan_dev_prod,
  ]
}
