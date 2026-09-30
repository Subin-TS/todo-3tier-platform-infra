output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "node_group_name" {
  description = "EKS managed node group name"
  value       = aws_eks_node_group.this.node_group_name
}
output "karpenter_controller_role_arn" {
  description = "IAM role ARN used by the Karpenter controller"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_arn" {
  description = "IAM role ARN used by Karpenter-provisioned nodes"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_node_instance_profile_name" {
  description = "EC2 instance profile used by Karpenter-provisioned nodes"
  value       = aws_iam_instance_profile.karpenter_node.name
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = aws_iam_openid_connect_provider.eks.url
}
