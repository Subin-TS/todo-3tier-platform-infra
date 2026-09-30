variable "name" {
  description = "Name prefix for RDS resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS DB subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}
