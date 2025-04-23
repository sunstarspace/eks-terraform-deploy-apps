variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "eks-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# variable "private_subnets" {
#   description = "Private subnets CIDR blocks"
#   type        = list(string)
#   default     = ["10.0.0.0/20", "10.0.16.0/20"]
# }

# variable "public_subnets" {
#   description = "Public subnets CIDR blocks"
#   type        = list(string)
#   default     = ["10.0.200.0/24", "10.0.100.0/24"]
# }

variable "project" {
  description = "The name of the project"
  type        = string
  default     = "EKS demo"
}

variable "contact" {
  description = "The contact persion for this cluster"
  type        = string
  default     = "example@example.com"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "eks-lomercy"
}

variable "eks_cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
  default     = "1.32"
}

# variable "eks_cluster_public_access_cidr" {
#   description = "Who can access the public endpoint of the cluster"
#   type        = list(any)
# }
