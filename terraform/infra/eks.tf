module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.35.0"

  cluster_name    = "${var.eks_cluster_name}-${terraform.workspace}"
  cluster_version = var.eks_cluster_version

  # Using the new authentication mode (at the time of this project - 2025)
  authentication_mode = "API"

  # bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # Allow public access for the Kubernetes API
  cluster_endpoint_public_access = true
  # cluster_endpoint_public_access_cidrs = var.eks_cluster_public_access_cidr

  # Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # Network configuration
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  # control_plane_subnet_ids = module.vpc.public_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    eks_mgmt_group = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m6i.large"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  # Add cluster role which grants full access to the cluster
  access_entries = {
    eks_admins = {
      # the role bellow is created during the setup phase (check setup/iam.tf file)
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-admins-role"
      type          = "STANDARD"
      policy_associations = {
        cluster_admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${data.aws_region.current.id}"
  }

  depends_on = [module.eks]
}
