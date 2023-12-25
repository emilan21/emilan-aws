# API Gateway
resource "aws_api_gateway_rest_api" "eric_milan_dev_prod" {
  provider = aws.prod
  name     = "ericmilandevprod"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "counts" {
  provider    = aws.prod
  path_part   = "counts"
  parent_id   = aws_api_gateway_rest_api.eric_milan_dev_prod.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.eric_milan_dev_prod.id
}

resource "aws_api_gateway_resource" "get_counts" {
  provider    = aws.prod
  path_part   = "get"
  parent_id   = aws_api_gateway_resource.counts.id
  rest_api_id = aws_api_gateway_rest_api.eric_milan_dev_prod.id
}

resource "aws_api_gateway_resource" "increment_counts" {
  provider    = aws.prod
  path_part   = "increment"
  parent_id   = aws_api_gateway_resource.counts.id
  rest_api_id = aws_api_gateway_rest_api.eric_milan_dev_prod.id
}

resource "aws_api_gateway_method" "get_counts_method" {
  provider      = aws.prod
  rest_api_id   = aws_api_gateway_rest_api.eric_milan_dev_prod.id
  resource_id   = aws_api_gateway_resource.get_counts.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "increment_counts_method" {
  provider      = aws.prod
  rest_api_id   = aws_api_gateway_rest_api.eric_milan_dev_prod.id
  resource_id   = aws_api_gateway_resource.increment_counts.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_counts_integration" {
  provider                = aws.prod
  rest_api_id             = aws_api_gateway_rest_api.eric_milan_dev_prod.id
  resource_id             = aws_api_gateway_resource.get_counts.id
  http_method             = aws_api_gateway_method.get_counts_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.get_visit_count_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "increment_counts_integration" {
  provider                = aws.prod
  rest_api_id             = aws_api_gateway_rest_api.eric_milan_dev_prod.id
  resource_id             = aws_api_gateway_resource.increment_counts.id
  http_method             = aws_api_gateway_method.increment_counts_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.increment_visit_count_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "get_counts_response_200" {
  provider    = aws.prod
  rest_api_id = aws_api_gateway_rest_api.eric_milan_dev_prod.id
  resource_id = aws_api_gateway_resource.get_counts.id
  http_method = aws_api_gateway_method.get_counts_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "increment_counts_response_200" {
  provider    = aws.prod
  rest_api_id = aws_api_gateway_rest_api.eric_milan_dev_prod.id
  resource_id = aws_api_gateway_resource.increment_counts.id
  http_method = aws_api_gateway_method.increment_counts_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "get_counts_integration_response" {
  provider    = aws.prod
  rest_api_id = aws_api_gateway_rest_api.eric_milan_dev_prod.id
  resource_id = aws_api_gateway_resource.get_counts.id
  http_method = aws_api_gateway_method.get_counts_method.http_method
  status_code = aws_api_gateway_method_response.get_counts_response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOF
EOF
  }
}

resource "aws_api_gateway_integration_response" "increment_counts_integration_response" {
  provider    = aws.prod
  rest_api_id = aws_api_gateway_rest_api.eric_milan_dev_prod.id
  resource_id = aws_api_gateway_resource.increment_counts.id
  http_method = aws_api_gateway_method.increment_counts_method.http_method
  status_code = aws_api_gateway_method_response.increment_counts_response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOF
EOF
  }
}

resource "aws_api_gateway_deployment" "eric_milan_dev_prod" {
  provider    = aws.prod
  rest_api_id = aws_api_gateway_rest_api.eric_milan_dev_prod.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.get_counts.id,
      aws_api_gateway_method.get_counts_method.id,
      aws_api_gateway_integration.get_counts_integration.id,
      aws_api_gateway_resource.increment_counts.id,
      aws_api_gateway_method.increment_counts_method.id,
      aws_api_gateway_integration.increment_counts_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "eric_milan_dev_prod" {
  provider      = aws.prod
  depends_on    = [aws_cloudwatch_log_group.stage_eric_milan_dev_prod]
  deployment_id = aws_api_gateway_deployment.eric_milan_dev_prod.id
  rest_api_id   = aws_api_gateway_rest_api.eric_milan_dev_prod.id
  stage_name    = var.stage_name
}

output "eric_milan_dev_prod_api_url" {
  description = "API URL"
  value       = aws_api_gateway_stage.eric_milan_dev_prod.invoke_url
}
