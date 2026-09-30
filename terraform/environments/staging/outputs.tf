output "application_github_actions_role_arn" {
  description = "IAM role ARN used by the application GitHub Actions pipeline"
  value       = module.github_actions.application_role_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for application images"
  value       = module.ecr.repository_urls
}
