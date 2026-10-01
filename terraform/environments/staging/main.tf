terraform {
  backend "s3" {
    bucket = "todo-3tier-platform-terraform-state-275839157288"
    key    = "staging/terraform.tfstate"
    region = "ap-south-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.66"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }

  }
  required_version = ">= 1.16"

}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.aws_eks_cluster.this.name,
        "--region",
        var.aws_region,
      ]
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.this.name,
      "--region",
      var.aws_region,
    ]
  }
}


data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}
module "vpc" {
  source = "../../modules/vpc"

  name = "todo-staging"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}
module "eks" {
  source = "../../modules/eks"

  cluster_name       = "todo-staging"
  cluster_version    = "1.36"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = ["t3.small"]

  node_min_size     = 1
  node_desired_size = 2
  node_max_size     = 3
}

module "rds" {
  source = "../../modules/rds"

  name               = "todo-staging"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  db_name     = "todo"
  db_username = var.db_username
  db_password = random_password.db.result

  instance_class    = "db.t3.micro"
  allocated_storage = 20
}

module "secrets_manager" {
  source = "../../modules/secrets-manager"

  name        = "todo-staging-db"
  db_username = var.db_username
  db_password = random_password.db.result
  db_name     = "todo"
  db_port     = 3306
}

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+?"
}

module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "todo-frontend",
    "todo-backend"
  ]
}

module "github_actions" {
  source = "../../modules/github-actions"

  github_org    = "Subin-TS"
  github_repo   = "todo-3tier-platform"
  github_branch = "main"

  role_name = "todo-staging-github-actions-app"

  ecr_repository_arns = values(module.ecr.repository_arns)
}

resource "kubernetes_manifest" "todo_staging_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "todo-staging"
      namespace = "argocd"
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/Subin-TS/todo-3tier-platform.git"
        targetRevision = "main"
        path           = "helm/todo-app"

        helm = {
          valueFiles = [
            "values-staging.yaml"
          ]
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "todo-staging"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }

        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}

module "aws_load_balancer_controller" {
  source = "../../modules/aws-load-balancer-controller"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  vpc_id            = module.vpc.vpc_id
  region            = var.aws_region
}

resource "kubernetes_manifest" "gitops_root_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "gitops-root"
      namespace = "argocd"
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/Subin-TS/todo-3tier-platform.git"
        targetRevision = "main"
        path           = "gitops"
        directory = {
          recurse = true
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}

module "github_actions_infra" {
  source = "../../modules/github-actions-infra"

  github_org      = "Subin-TS"
  github_repo     = "todo-3tier-platform-infra"
  github_owner_id = "104053006"
  github_repo_id  = "1392365040"
  github_branch   = "main"
  role_name       = "todo-staging-github-actions-infra"
}

resource "aws_eks_access_entry" "github_actions_infra" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_actions_infra.infrastructure_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_infra_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_actions_infra.infrastructure_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
