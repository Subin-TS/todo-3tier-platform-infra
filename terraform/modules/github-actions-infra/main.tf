data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "infrastructure" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}:ref:refs/heads/${var.github_branch}"
          }
        }
      }
    ]
  })

  tags = {
    Name        = var.role_name
    ManagedBy   = "Terraform"
    Purpose     = "GitHub Actions infrastructure CI/CD"
    Repository  = "${var.github_org}/${var.github_repo}"
  }
}

resource "aws_iam_role_policy_attachment" "administrator" {
  role       = aws_iam_role.infrastructure.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
