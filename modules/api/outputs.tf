output "get_lambda_arn" {
  value = aws_lambda_function.get_message.arn
}

output "post_lambda_arn" {
  value = aws_lambda_function.post_message.arn
}

output "api_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/prod/messages"
}