# terraform-aws-lambda

This Terraform module can be used for deploying a prepackaged lambda function and hides the ugly parts from you.
It expects that the function has already been deployed to amazon s3.

After version 11.4 this module supports HCL2 and will not work with versions of Terraform prior to 0.12

## Features

* Only appears in the Terraform plan when there are legitimate changes.
* Creates a standard IAM role and policy for CloudWatch Logs as well as the actual logs.
  * You can add additional policies if required.

## Requirements

* terraform
* Linux/Unix/Windows

## Usage

```js
module "lambda" {
  source = "github.com/krystan/terraform-aws-lambda"

  lambda_function_name = "deployment-deploy-status"
  description          = "Deployment deploy status task"
  lambda_handler       = "main.lambda_handler"
  lambda_runtime       = "python3.6"
  timeout              = 300
  s3_bucket            = "youruniquebucketnamehere"

  // Attach a policy.
  policy        = data.aws_iam_policy_document.lambda.json

  dead_letter_config {
    target_arn = var.dead_letter_queue_arn
  }

  // Add environment variables.
  environment {
    variables {
      SLACK_URL = var.slack_url
    }
  }

  // Deploy into a VPC.
  attach_vpc_config = true
  vpc_config {
    subnet_ids         = [aws_subnet.test.id]
    security_group_ids = [aws_security_group.test.id]
  }
}
```

### NB - Multi-region usage

IAM and Lambda function names need to be globally unique within your account.
If you will be deploying this template to multiple regions, you must make the
function name unique per region, for example by setting
`function_name = "deployment-deploy-status-${data.aws_region.current.name}"`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attach\_dead\_letter\_config | Set this to true if using the dead_letter_config variable | string | `"false"` | no |
| attach\_policy | Set this to true if using the policy variable | string | `"false"` | no |
| attach\_vpc\_config | Set this to true if using the vpc_config variable | string | `"false"` | no |
| dead\_letter\_config | Dead letter configuration for the Lambda function | map | `<map>` | no |
| description | Description of what your Lambda function does | string | `"Managed by Terraform"` | no |
| enable\_cloudwatch\_logs | Set this to false to disable logging your Lambda output to CloudWatch Logs | string | `"true"` | no |
| environment | Environment configuration for the Lambda function | map | `<map>` | no |
| function\_name | A unique name for your Lambda function (and related IAM resources) | string | n/a | yes |
| lambda_handler | The function entrypoint in your code | string | n/a | yes |
| lambda\_at\_edge | Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function | string | `"false"` | no |
| memory\_size | Amount of memory in MB your Lambda function can use at runtime | string | `"128"` | no |
| policy | An addional policy to attach to the Lambda function | string | `""` | no |
| publish | Whether to publish creation/change as new Lambda Function Version | string | `"false"` | no |
| reserved\_concurrent\_executions | The amount of reserved concurrent executions for this Lambda function | string | `"-1"` | no |
| lambda_runtime | The runtime environment for the Lambda function | string | n/a | yes |
| tags | A mapping of tags | map | `<map>` | no |
| timeout | The amount of time your Lambda function had to run in seconds | string | `"10"` | no |
| vpc\_config | VPC configuration for the Lambda function | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | The ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |
| cloudwatch\_log\_group\_name| The name of the log group for cloudwatch if enabled |
| cloudwatch\_log\_group\_arn| The arn of the log group for cloudwatch if enabled |
