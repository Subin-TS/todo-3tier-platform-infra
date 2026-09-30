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
  }
  required_version = ">= 1.16"

}

provider "aws" {
  region  = var.aws_region
  profile = "saints"
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
