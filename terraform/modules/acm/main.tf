resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name      = var.domain_name
    ManagedBy = "Terraform"
    Purpose   = "ALB HTTPS certificate"
  }
}

output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "domain_validation_options" {
  description = "DNS validation records required by ACM"
  value       = aws_acm_certificate.this.domain_validation_options
}
