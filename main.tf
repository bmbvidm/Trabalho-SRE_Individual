resource "aws_sqs_queue" "command_queue" {
  name = "command-queue"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Policy for Lambda to access SQS and logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.command_queue.arn
      },
      {
        Action   = "logs:*"
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "queryLambda" {
  function_name    = "query-lambda"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_role.arn
  handler          = "queryLambda.handler"
  filename         = "C:/Users/Mikasa TU Cassa/Desktop/Project/lambdas/queryLambda.zip"
  source_code_hash = filebase64sha256("C:/Users/Mikasa TU Cassa/Desktop/Project/lambdas/queryLambda.zip")
}

resource "aws_lambda_function" "commandLambda" {
  function_name    = "command-lambda"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_role.arn
  handler          = "commandLambda.handler"
  filename         = "C:/Users/Mikasa TU Cassa/Desktop/Project/lambdas/commandLambda.zip"
  source_code_hash = filebase64sha256("C:/Users/Mikasa TU Cassa/Desktop/Project/lambdas/commandLambda.zip")
}

resource "aws_api_gateway_rest_api" "query_api" {
  name = "query-api"
}

resource "aws_api_gateway_resource" "query_resource" {
  rest_api_id = aws_api_gateway_rest_api.query_api.id
  parent_id   = aws_api_gateway_rest_api.query_api.root_resource_id
  path_part   = "query"
}

resource "aws_api_gateway_method" "query_method" {
  rest_api_id   = aws_api_gateway_rest_api.query_api.id
  resource_id   = aws_api_gateway_resource.query_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id            = aws_api_gateway_rest_api.query_api.id
  resource_id            = aws_api_gateway_resource.query_resource.id
  http_method            = aws_api_gateway_method.query_method.http_method
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.queryLambda.invoke_arn
}

resource "aws_api_gateway_deployment" "query_api" {
  rest_api_id = aws_api_gateway_rest_api.query_api.id
  stage_name  = "prod"
  depends_on  = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.command_queue.arn
  function_name    = aws_lambda_function.commandLambda.arn
  batch_size       = 10
  enabled          = true
}
