variable "s3BucketName" {
  type    = "string"
  default = ""
}

variable "lambda_function_name" {
  type = "string"
}

variable "lambda_version" {
  type = "string"
}

variable "lambda_code_filename" {
  type = "string"
}

variable "lambda_runtime" {
  type = "string"
}

variable "lambda_memory_size" {
  type    = "string"
  default = 128
}

variable "cloudwatch_log_retention_in_days" {
  type    = "string"
  default = 14
}

variable "lambda_handler" {
  type = "string"
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this Lambda function"
  type        = "string"
  default     = -1
}

variable "description" {
  type    = "string"
  default = "Managed by Terraform"
}

variable "timeout" {
  type    = "string"
  default = 15
}

variable "attach_dead_letter_config" {
  type    = "string"
  default = false
}

variable "dead_letter_config" {
  description = "Dead letter configuration for the Lambda function"
  type        = "map"
  default     = {}
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type        = "map"
  default     = {}
}

variable "attach_vpc_config" {
  description = "Set this to true if using the vpc_config variable"
  type        = "string"
  default     = false
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version"
  type        = "string"
  default     = false
}

variable "attach_policy" {
  description = "Set this to true if using the policy variable"
  type        = "string"
  default     = false
}

variable "policy" {
  description = "An addional policy to attach to the Lambda function"
  type        = "string"
  default     = ""
}

variable "enable_cloudwatch_logs" {
  description = "Set this to false to disable logging your Lambda output to CloudWatch Logs"
  type        = "string"
  default     = true
}

variable "lambda_at_edge" {
  description = "Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function"
  type        = "string"
  default     = false
}

variable "environmentmental_vars" {
  description = "Environment configuration for the Lambda function"
  type        = "map"
  default     = {}
}

variable "tags" {
  description = "Tags for resources"
  default     = {}
}

locals {
  publish = "${var.lambda_at_edge ? true : var.publish}"
  timeout = "${var.lambda_at_edge ? min(var.timeout, 5) : var.timeout}"
}
