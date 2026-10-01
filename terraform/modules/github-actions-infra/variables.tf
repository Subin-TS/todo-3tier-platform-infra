variable "github_org" {
  description = "GitHub organization or user owning the repository"
  type        = string
}

variable "github_repo" {
  description = "Infrastructure GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the infrastructure role"
  type        = string
  default     = "main"
}

variable "role_name" {
  description = "IAM role name for the infrastructure GitHub Actions pipeline"
  type        = string
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID used by the OIDC subject claim"
  type        = string
}

variable "github_repo_id" {
  description = "Immutable GitHub repository ID used by the OIDC subject claim"
  type        = string
}
