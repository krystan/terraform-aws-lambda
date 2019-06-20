output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "function_invoke_arn" {
  description = "The invoke ARN of the lambda function"
  value       = aws_lambda_function.lambda_function.invoke_arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.lambda_function.name
}

output "function_qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.qualified_arn
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda-iam-role.arn
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda-iam-role.name
}

output "cloudwatch_log_group_name" {
  description = "The name of the cludwatch_log_group"
  value       = aws_cloudwatch_log_group.lambda.*.name
}

output "cloudwatch_log_group_arn" {
  description = "The name of the cludwatch_log_group"
  value       = aws_cloudwatch_log_group.lambda.*.arn
}

