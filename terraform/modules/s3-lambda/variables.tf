variable "bucket_name" {
  description = "Name of the S3 bucket used for application event uploads"
  type        = string
}

variable "lambda_name" {
  description = "Name of the Lambda function triggered by S3"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.13"
}
