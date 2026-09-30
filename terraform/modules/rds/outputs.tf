output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "RDS instance hostname"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.this.port
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.this.id
}
