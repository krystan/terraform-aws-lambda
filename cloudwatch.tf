resource "aws_cloudwatch_log_group" "lambda" {
  count             = "${var.enable_cloudwatch_logs ? 1 : 0}"
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = "${var.cloudwatch_log_retention_in_days}"
}
