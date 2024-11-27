# API Gateway REST
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.project_name}-api"
}

resource "aws_api_gateway_resource" "commands" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "commands"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.commands.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_commands" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.commands.id
  http_method             = aws_api_gateway_method.post_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.commands_lambda.invoke_arn
}

# Fila SQS para comandos assíncronos
resource "aws_sqs_queue" "commands_queue" {
  name = "${var.project_name}-commands-queue"
}

# Lambda para consultas
resource "aws_lambda_function" "queries_lambda" {
  filename         = "queries_lambda.zip" # Código compactado
  function_name    = "${var.project_name}-queries"
  role             = aws_iam_role.lambda_role.arn
  handler          = "queries.handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("queries_lambda.zip")
}

# Lambda para comandos
resource "aws_lambda_function" "commands_lambda" {
  filename         = "commands_lambda.zip"
  function_name    = "${var.project_name}-commands"
  role             = aws_iam_role.lambda_role.arn
  handler          = "commands.handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("commands_lambda.zip")
  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.commands_queue.id
    }
  }
}

# Permissão para API Gateway chamar Lambda
resource "aws_lambda_permission" "apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.commands_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

# Role para Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}
