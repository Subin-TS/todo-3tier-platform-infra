variable "name" {
  description = "Name of the Secrets Manager secret"
  type        = string
}

variable "db_username" {
  description = "Database username stored in the secret"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password stored in the secret"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name stored in the secret"
  type        = string
}

variable "db_port" {
  description = "Database port stored in the secret"
  type        = number
  default     = 3306
}
