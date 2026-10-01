output "infrastructure_role_arn" {
  description = "IAM role ARN for the infrastructure GitHub Actions pipeline"
  value       = aws_iam_role.infrastructure.arn
}
