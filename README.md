# Todo Platform — AWS Infrastructure Repository

This repository contains Terraform code and infrastructure CI/CD for the AWS Cloud & DevOps capstone. The application source, Dockerfiles, Helm chart and application CI/CD live in the separate [`todo-3tier-platform`](https://github.com/Subin-TS/todo-3tier-platform) repository.

**Region used in the capstone:** `ap-south-1`  
**Environment:** staging

## Infrastructure overview

The original Terraform-managed platform included:
- Amazon VPC, public/private subnets, route tables, Internet Gateway and NAT Gateway
- Amazon EKS and managed node group
- Karpenter for dynamic Kubernetes node provisioning
- Amazon ECR repositories for frontend/backend images
- Amazon RDS for MySQL
- IAM roles/policies and EKS Access Entries
- AWS Load Balancer Controller and Application Load Balancer
- ACM certificate for HTTPS and the `www.devopslok.in` hostname
- AWS Secrets Manager and External Secrets integration
- S3 and Lambda serverless event-processing capability
- S3-backed Terraform remote state in the original setup

## Diagram 4.4 — Infrastructure pipeline

![Diagram 4.4: Terraform Infrastructure Pipeline](docs/images/diagram-4.4-infrastructure-pipeline.png)

The infrastructure pipeline starts with a developer change to the infrastructure repository. GitHub Actions runs Terraform initialization, validation, planning and apply stages. GitHub OIDC federates to an AWS IAM role. Terraform provisions AWS resources and stores state in the S3 backend.

## Application and infrastructure separation

The infrastructure repository owns AWS platform provisioning. The application repository owns application image build/publish and Helm/GitOps delivery.

Typical flow:
1. Infrastructure CI/CD provisions AWS resources with Terraform.
2. Application CI/CD tests/scans images and pushes them to ECR.
3. GitOps changes are reconciled by Argo CD into EKS.
4. Argo Rollouts manages progressive frontend releases.
5. RDS provides persistence; Secrets Manager/External Secrets provides credentials.
6. Prometheus/Grafana provide metrics and dashboards; the serverless Lambda function writes logs to CloudWatch.

## Repository organization

Known areas include `terraform/environments/staging`, reusable Terraform modules, and GitHub Actions workflow files. Modules cover areas such as VPC, EKS, ECR, RDS, secrets, ACM, AWS Load Balancer Controller and S3/Lambda. Refer to the checked-in repository tree for exact paths and names.

## Prerequisites

- AWS CLI and an authorized AWS profile
- Terraform compatible with the repository's lock file
- Correct AWS account and region
- Required AWS IAM permissions and EKS access configuration
- Valid S3 backend and configured state locking, if used
- GitHub OIDC trust/role configuration for the infrastructure workflow

## Critical backend status

The capstone AWS resources were deleted after project completion. The original Terraform remote-state S3 bucket was also deleted, and the local Terraform state available during cleanup was empty/incomplete. Therefore, the previous state cannot be assumed recoverable.

**Do not run `terraform apply` or `terraform destroy` against the old incomplete state.**

Before redeployment:
1. Inspect the backend configuration in `terraform/environments/staging`.
2. Recreate/bootstrap a secure state bucket in the intended account/region, or intentionally configure a safe disposable-lab backend.
3. Do not use the old backup state as authoritative.
4. Review resource names, variables, IAM permissions, provider lock file, quotas and expected costs.

## Standard Terraform workflow

From the intended environment directory:

```bash
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan
```

Review the complete plan and verify account, region, resource changes and costs. Only after review/approval:

```bash
terraform apply
```

If the project uses a GitHub Actions Terraform workflow, follow the repository's workflow and approval process rather than applying manually. Never apply blindly.

## Security and cost controls

- Prefer GitHub OIDC and least-privilege IAM instead of long-lived access keys.
- Never commit secret values, sensitive `.tfvars`, Terraform state, plan files or kubeconfig.
- Keep RDS private and restrict security-group access.
- Avoid secret values in Terraform outputs/logs.
- Tag resources and set budget alerts.
- EKS, RDS, NAT Gateway, ALB and data transfer can incur charges.

## Runbook

See [`RUNBOOK.md`](RUNBOOK.md) for backend bootstrap, preflight checks, plan review, provisioning, validation, troubleshooting and safe cleanup.
