############ Data source to query availability zones in the region
data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

############ VPC module:
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  # VPC Configuration
  name = "${var.vpc_name}-${terraform.workspace}"
  cidr = var.vpc_cidr

  # Enable Public Subnets and NAT Gateway
  enable_nat_gateway = true
  single_nat_gateway = true

  # Subnets Configuration
  # azs = slice(data.aws_availability_zones.available.names, 0, 3) # Limit to 3 AZs - TO DELETE????
  azs = local.azs
  # private_subnets = var.private_subnets
  # public_subnets  = var.public_subnets
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 100)]

  # DNS Configuration
  enable_dns_support   = true
  enable_dns_hostnames = true

  # To deploy load balancers to a subnet, the subnet must have the following tag
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  # Main tags
  tags = {
    "VPC" = var.vpc_name
  }
}

