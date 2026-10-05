output "bucket_name" {
  description = "Name of the S3 upload bucket"
  value       = aws_s3_bucket.uploads.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 upload bucket"
  value       = aws_s3_bucket.uploads.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.name
}
