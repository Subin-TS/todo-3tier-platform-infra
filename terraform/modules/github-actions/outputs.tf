output "application_role_arn" {
  description = "IAM role ARN for the application GitHub Actions pipeline"
  value       = aws_iam_role.application.arn
}
