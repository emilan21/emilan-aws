data "aws_iam_policy_document" "assume_role" {
  provider = aws.prod
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
  provider           = aws.prod
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  provider    = archive.prod
  type        = "zip"
  source_file = "../emilan-website/backend/lambda.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "eric_milan_dev_prod" {
  provider = aws.prod
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_backend_api"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      foo = "bar"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.eric_milan_dev_prod,
  ]
}
