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
