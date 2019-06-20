data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
      # force an interpolation expression to be interpreted as a list by wrapping it
      # in an extra set of list brackets. That form was supported for compatibilty in
      # v0.11, but is no longer supported in Terraform v0.12.
      #
      # If the expression in the following list itself returns a list, remove the
      # brackets to avoid interpretation as a list of lists. If the expression
      # returns a single list item then leave it as-is and remove this TODO comment.
      identifiers = [slice(
        ["lambda.amazonaws.com", "edgelambda.amazonaws.com"],
        0,
        var.lambda_at_edge ? 2 : 1,
      )]
    }
  }
}

resource "aws_iam_role" "lambda-iam-role" {
  name               = var.lambda_function_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

locals {
  lambda_log_group_arn      = "arn:${data.aws_partition.current.partition}:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_function_name}"
  lambda_edge_log_group_arn = "arn:${data.aws_partition.current.partition}:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/us-east-1.${var.lambda_function_name}"
  log_group_arns = [slice(
    [local.lambda_log_group_arn, local.lambda_edge_log_group_arn],
    0,
    var.lambda_at_edge ? 2 : 1,
  )]
}

data "aws_iam_policy_document" "logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = concat(
      formatlist("%v:*", local.log_group_arns),
      formatlist("%v:*:*", local.log_group_arns),
    )
  }
}

resource "aws_iam_policy" "logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name   = "${var.lambda_function_name}-logs"
  policy = data.aws_iam_policy_document.logs[0].json
}

resource "aws_iam_policy_attachment" "logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name       = "${var.lambda_function_name}-logs"
  roles      = [aws_iam_role.lambda-iam-role.name]
  policy_arn = aws_iam_policy.logs[0].arn
}

data "aws_iam_policy_document" "network" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "network" {
  count = var.attach_vpc_config ? 1 : 0

  name   = "${var.lambda_function_name}-network"
  policy = data.aws_iam_policy_document.network.json
}

resource "aws_iam_policy_attachment" "network" {
  count = var.attach_vpc_config ? 1 : 0

  name       = "${var.lambda_function_name}-network"
  roles      = [aws_iam_role.lambda-iam-role.name]
  policy_arn = aws_iam_policy.network[0].arn
}

resource "aws_iam_policy" "additional" {
  count = var.attach_policy ? 1 : 0

  name   = var.lambda_function_name
  policy = var.policy
}

resource "aws_iam_policy_attachment" "additional" {
  count = var.attach_policy ? 1 : 0

  name       = var.lambda_function_name
  roles      = [aws_iam_role.lambda-iam-role.name]
  policy_arn = aws_iam_policy.additional[0].arn
}

data "aws_iam_policy_document" "dead_letter" {
  count = var.attach_dead_letter_config ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
      "sqs:SendMessage",
    ]

    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibilty in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    resources = [
      lookup(var.dead_letter_config, "target_arn", ""),
    ]
  }
}

resource "aws_iam_policy" "dead_letter" {
  count = var.attach_dead_letter_config ? 1 : 0

  name   = "${var.lambda_function_name}-dl"
  policy = data.aws_iam_policy_document.dead_letter[0].json
}

