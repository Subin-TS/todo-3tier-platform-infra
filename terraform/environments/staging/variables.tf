variable "aws_region" {
  description = "AWS region for the staging environment"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for the staging VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for the staging VPC"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for staging public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for staging private subnets"
  type        = list(string)
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

