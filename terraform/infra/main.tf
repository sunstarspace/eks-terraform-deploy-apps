terraform {
  required_version = "~> 1.11.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.94.1"
    }
  }

  backend "s3" {
    bucket       = "eks-sunstar-apps-tfstate"
    key          = "tfstate-infra"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # new way of locking as the dynamodb way is deprecated.
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform"
  default_tags {
    tags = {
      Environment = terraform.workspace
      Project     = var.project
      Contact     = var.contact
      Terraform   = "true"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
