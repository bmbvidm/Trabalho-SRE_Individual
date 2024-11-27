output "api_gateway_url" {
  value = aws_api_gateway_rest_api.api.execution_arn
  description = "URL base do API Gateway."
}

output "sqs_queue_url" {
  value = aws_sqs_queue.commands_queue.id
  description = "URL da fila SQS."
}

output "lambda_queries_arn" {
  value = aws_lambda_function.queries_lambda.arn
  description = "ARN da Lambda de consultas."
}

output "lambda_commands_arn" {
  value = aws_lambda_function.commands_lambda.arn
  description = "ARN da Lambda de comandos."
}
