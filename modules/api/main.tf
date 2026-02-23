data "aws_region" "current" {}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "jatin-serverless-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# CloudWatch logs permissions
resource "aws_iam_role_policy_attachment" "basic_exec" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB least privilege
data "aws_iam_policy_document" "ddb_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:Scan"
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/${var.table_name}"
    ]
  }
}

resource "aws_iam_policy" "ddb_access" {
  name   = "jatin-serverless-ddb-access"
  policy = data.aws_iam_policy_document.ddb_policy.json
}

resource "aws_iam_role_policy_attachment" "ddb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ddb_access.arn
}

# Package lambdas (zip single file)
data "archive_file" "get_zip" {
  type        = "zip"
  source_file = "${path.root}/lambda/getMessage.js"
  output_path = "${path.root}/lambda/getMessage.zip"
}

data "archive_file" "post_zip" {
  type        = "zip"
  source_file = "${path.root}/lambda/postMessage.js"
  output_path = "${path.root}/lambda/postMessage.zip"
}

resource "aws_lambda_function" "get_message" {
  function_name = "jatin-getMessage"
  role          = aws_iam_role.lambda_role.arn
  handler       = "getMessage.handler"
  runtime       = "nodejs20.x"

  filename         = data.archive_file.get_zip.output_path
  source_code_hash = data.archive_file.get_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }

  tags = {
    Environment = "dev"
  }
}

resource "aws_lambda_function" "post_message" {
  function_name = "jatin-postMessage"
  role          = aws_iam_role.lambda_role.arn
  handler       = "postMessage.handler"
  runtime       = "nodejs20.x"

  filename         = data.archive_file.post_zip.output_path
  source_code_hash = data.archive_file.post_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }

  tags = {
    Environment = "dev"
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name = "jatin-serverless-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "messages" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "messages"
}
resource "aws_api_gateway_method" "get_messages" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.messages.id
  http_method             = aws_api_gateway_method.get_messages.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_message.invoke_arn
}

resource "aws_api_gateway_method" "post_message" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.messages.id
  http_method             = aws_api_gateway_method.post_message.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_message.invoke_arn
}



resource "aws_lambda_permission" "allow_get" {
  statement_id  = "AllowExecutionFromAPIGatewayGET"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_message.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_post" {
  statement_id  = "AllowExecutionFromAPIGatewayPOST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_message.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method_response.options_response
  ]
}


resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.get_integration,
    aws_api_gateway_integration.post_integration,
    aws_api_gateway_integration.options_integration,
    aws_api_gateway_integration_response.options_integration_response
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_method.get_messages.id,
      aws_api_gateway_method.post_message.id,
      aws_api_gateway_method.options.id,
      aws_api_gateway_integration.get_integration.id,
      aws_api_gateway_integration.post_integration.id,
      aws_api_gateway_integration.options_integration.id,
      aws_api_gateway_method_response.options_response.id,
      aws_api_gateway_integration_response.options_integration_response.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = "prod"
}