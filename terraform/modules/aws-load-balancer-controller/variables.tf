variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC issuer URL for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "controller_namespace" {
  description = "Kubernetes namespace for AWS Load Balancer Controller"
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Kubernetes service account used by AWS Load Balancer Controller"
  type        = string
  default     = "aws-load-balancer-controller"
}
