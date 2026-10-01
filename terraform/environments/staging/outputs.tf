output "application_github_actions_role_arn" {
  description = "IAM role ARN used by the application GitHub Actions pipeline"
  value       = module.github_actions.application_role_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for application images"
  value       = module.ecr.repository_urls
}

output "rds_address" {
  description = "RDS MySQL endpoint address"
  value       = module.rds.db_instance_address
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN for the application"
  value       = module.acm.certificate_arn
}

output "acm_domain_validation_options" {
  description = "ACM DNS validation records"
  value       = module.acm.domain_validation_options
}
