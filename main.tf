resource "aws_lambda_function" "lambda_function" {
  function_name                  = var.lambda_function_name
  description                    = var.description
  role                           = aws_iam_role.lambda-iam-role.arn
  handler                        = var.lambda_handler
  reserved_concurrent_executions = var.reserved_concurrent_executions
  runtime                        = var.lambda_runtime
  timeout                        = local.timeout
  s3_bucket                      = var.s3BucketName
  s3_key                         = "v${var.lambda_version}/${var.lambda_code_filename}"
  memory_size                    = var.lambda_memory_size

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config == null ? [] : [var.dead_letter_config]
    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }

  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = environment.value.variables
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config == null ? [] : [var.tracing_config]
    content {
      mode = tracing_config.value.mode
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }
}
