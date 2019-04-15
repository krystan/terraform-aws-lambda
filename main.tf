#
# N.B
# 
# The 'lambda_function' resource is considered the master
# it is important the all the other lambda resource below the marked line
# match the configuration of the master when the field names are the same
#

resource "aws_lambda_function" "lambda_function" {
  count                          = "${! var.attach_vpc_config && ! var.attach_dead_letter_config ? 1 : 0}"
  function_name                  = "${var.lambda_function_name}"
  description                    = "${var.description}"
  role                           = "${aws_iam_role.lambda-iam-role.arn}"
  handler                        = "${var.lambda_handler}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.lambda_runtime}"
  timeout                        = "${local.timeout}"
  s3_bucket                      = "${var.s3BucketName}"
  s3_key                         = "v${var.lambda_version}/${var.lambda_code_filename}"
  memory_size                    = "${var.lambda_memory_size}"

  # environmental variables
  environment = ["${slice( list(var.environmentmental_vars), 0, length(var.environmentmental_vars) == 0 ? 0 : 1 )}"]
}

# Below this line everything with the same field name should match the 'lambda' resource
resource "aws_lambda_function" "lambda_function_with_dl" {
  count = "${var.attach_dead_letter_config && ! var.attach_vpc_config ? 1 : 0}"

  dead_letter_config {
    target_arn = "${var.dead_letter_config["target_arn"]}"
  }

  function_name                  = "${var.lambda_function_name}"
  description                    = "${var.description}"
  role                           = "${aws_iam_role.lambda-iam-role.arn}"
  handler                        = "${var.lambda_handler}"
  memory_size                    = "${var.lambda_memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.lambda_runtime}"
  timeout                        = "${local.timeout}"
  s3_bucket                      = "${var.s3BucketName}"
  s3_key                         = "v${var.lambda_version}/${var.lambda_code_filename}"
  publish                        = "${local.publish}"
  tags                           = "${var.tags}"
  environment                    = ["${slice( list(var.environmentmental_vars), 0, length(var.environmentmental_vars) == 0 ? 0 : 1 )}"]
}

resource "aws_lambda_function" "lambda_with_vpc" {
  count = "${var.attach_vpc_config && ! var.attach_dead_letter_config ? 1 : 0}"

  function_name                  = "${var.lambda_function_name}"
  description                    = "${var.description}"
  role                           = "${aws_iam_role.lambda-iam-role.arn}"
  handler                        = "${var.lambda_handler}"
  memory_size                    = "${var.lambda_memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.lambda_runtime}"
  timeout                        = "${local.timeout}"
  s3_bucket                      = "${var.s3BucketName}"
  s3_key                         = "v${var.lambda_version}/${var.lambda_code_filename}"
  publish                        = "${local.publish}"
  tags                           = "${var.tags}"
  environment                    = ["${slice( list(var.environmentmental_vars), 0, length(var.environmentmental_vars) == 0 ? 0 : 1 )}"]

  vpc_config {
    security_group_ids = ["${var.vpc_config["security_group_ids"]}"]
    subnet_ids         = ["${var.vpc_config["subnet_ids"]}"]
  }
}

resource "aws_lambda_function" "lambda_with_dl_and_vpc" {
  count = "${var.attach_dead_letter_config && var.attach_vpc_config ? 1 : 0}"

  function_name                  = "${var.lambda_function_name}"
  description                    = "${var.description}"
  role                           = "${aws_iam_role.lambda-iam-role.arn}"
  handler                        = "${var.lambda_handler}"
  memory_size                    = "${var.lambda_memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.lambda_runtime}"
  timeout                        = "${local.timeout}"
  s3_bucket                      = "${var.s3BucketName}"
  s3_key                         = "v${var.lambda_version}/${var.lambda_code_filename}"
  publish                        = "${local.publish}"
  tags                           = "${var.tags}"
  environment                    = ["${slice( list(var.environmentmental_vars), 0, length(var.environmentmental_vars) == 0 ? 0 : 1 )}"]

  dead_letter_config {
    target_arn = "${var.dead_letter_config["target_arn"]}"
  }

  vpc_config {
    security_group_ids = ["${var.vpc_config["security_group_ids"]}"]
    subnet_ids         = ["${var.vpc_config["subnet_ids"]}"]
  }
}
