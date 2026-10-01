variable "github_org" {
  description = "GitHub organization or user owning the repository"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the role"
  type        = string
  default     = "main"
}

variable "role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs that GitHub Actions can push to"
  type        = list(string)
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID"
  type        = string
}

variable "github_repo_id" {
  description = "Immutable GitHub repository ID"
  type        = string
}
