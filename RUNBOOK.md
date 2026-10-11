# Infrastructure Operations Runbook

This runbook describes safe Terraform workflows for the AWS Todo platform.

## 1. Current-state warning

The capstone EKS cluster, RDS instance, ALB, ECR repositories, NAT Gateway, Elastic IPs, application S3 bucket and project VPC were removed. The default VPC was intentionally retained. The Terraform remote-state bucket was also deleted, and local state was incomplete.

**Do not run `terraform apply` or `terraform destroy` using the old state.** Bootstrap a valid backend and review the code/state before redeploying.

## 2. Verify identity and environment

```bash
aws sts get-caller-identity --profile saints
aws configure list --profile saints
aws eks list-clusters --region ap-south-1 --profile saints
aws rds describe-db-instances --region ap-south-1 --profile saints
aws ec2 describe-vpcs --region ap-south-1 --profile saints \
  --query 'Vpcs[*].[VpcId,IsDefault,CidrBlock,State]' --output table
```

Confirm account, profile, region and intended environment. Do not delete the default VPC.

## 3. Bootstrap the Terraform backend

1. Inspect the backend block in `terraform/environments/staging/main.tf`.
2. Recreate a secure state bucket in the correct account and region before initialization. Use a unique name, block public access, enable encryption and versioning, and restrict access.
3. Configure the state-locking mechanism supported by the repository's Terraform/backend version.
4. Confirm bucket, key, region and IAM permissions.
5. Initialize only after verifying backend configuration.

```bash
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan
```

Do not use `-reconfigure` or `-migrate-state` blindly. First establish where the authoritative state lives.

## 4. Review the plan

Verify:
- AWS account/profile and region
- VPC CIDR, subnet layout and routing
- NAT Gateway/EIP cost
- EKS version, managed node group, access entries, IAM and Karpenter
- ECR repository names/lifecycle rules
- RDS engine, subnet group, security groups, storage and backups
- Load Balancer Controller IAM setup
- ACM domain validation and DNS ownership
- Secrets Manager and S3/Lambda permissions
- GitHub OIDC trust and deployment role
- Terraform state backend and outputs

Only apply after reviewing the entire plan and expected cost.

## 5. Provisioning workflow

From `terraform/environments/staging`:

```bash
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

Treat plan files as potentially sensitive. Use the intended CI workflow and approval process where applicable.

## 6. Validate infrastructure

```bash
aws eks list-clusters --region ap-south-1 --profile saints
aws rds describe-db-instances --region ap-south-1 --profile saints
aws ecr describe-repositories --region ap-south-1 --profile saints
aws elbv2 describe-load-balancers --region ap-south-1 --profile saints
aws ec2 describe-nat-gateways --region ap-south-1 --profile saints
```

After configuring kubectl for the intended cluster:

```bash
kubectl get nodes
kubectl get pods -A
kubectl get ingress -A
kubectl get applications -A
```

Check EKS access, node readiness, ECR permissions, RDS network access, controller health, secret synchronization, ALB/TLS and DNS.

## 7. Handoff to application repo

Record only non-sensitive outputs: cluster name, region, ECR URIs, RDS endpoint, secret identifier, certificate ARN and hostname. Configure GitHub OIDC and the application repo's Helm/GitOps values. Do not commit credentials or sensitive Terraform outputs.

## 8. Troubleshooting

| Symptom | Checks |
|---|---|
| `terraform init` fails | Backend bucket, region/name/key, role permissions; the previous backend was deleted |
| Terraform state mismatch | Stop before applying; verify backend, lineage and resource ownership. Old backup is incomplete |
| EKS access denied | Caller identity, cluster auth mode, access entry and policy |
| Nodes not ready | Node group status, subnet routes, security groups, node role, capacity and quota |
| Karpenter not provisioning | Controller logs, NodePool/NodeClass, node role, subnet/security-group selectors and EC2 limits |
| ALB missing | Controller/IAM, ingress events, subnet tags, security groups, certificate and DNS |
| RDS unavailable | Instance status, subnet group, security groups, route path, endpoint and credential reference |
| CI workflow fails | OIDC trust, IAM permissions, backend access, variables and Terraform version |

## 9. Safe cleanup

For future deployments with valid state:
1. Verify account, region, backend and workspace.
2. Back up the authoritative state securely.
3. Review `terraform plan -destroy` and identify persistent data, snapshots, certificates and external DNS dependencies.
4. Obtain approval before deleting data.
5. Resolve dependencies such as ECR image contents, S3 object versions and ALB certificate attachment.
6. Destroy only after reviewing the plan.
7. Verify AWS resources and billing.

For the already-cleaned capstone, do not rerun destroy because the backend and full state are unavailable.

## 10. DNS

`www.devopslok.in` DNS is managed at GoDaddy, outside AWS. AWS cleanup does not remove DNS records. Remove/update only the project-specific record after confirming the ALB is gone; preserve unrelated records.
