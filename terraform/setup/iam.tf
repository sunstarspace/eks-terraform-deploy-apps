#######################################################################
# Create IAM user and policies for Continuous Deployment (CD) account #
#######################################################################

resource "aws_iam_user" "robot" {
  name = "robot"
}

resource "aws_iam_access_key" "robot" {
  user = aws_iam_user.robot.name
}

#########################################################
# Policy for Teraform backend to S3 and DynamoDB access #
#########################################################

data "aws_iam_policy_document" "tf_backend" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.tfstate_bucket}"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [
      "arn:aws:s3:::${var.tfstate_bucket}/tfstate-deploy/*",
      "arn:aws:s3:::${var.tfstate_bucket}/tfstate-deploy-env/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/${var.tfstate_lock_table}"]
  }
}

resource "aws_iam_policy" "tf_backend" {
  name        = "${aws_iam_user.robot.name}-tf-s3-dynamodb"
  description = "Allow user to use S3 and DynamoDB for TF backend resources"
  policy      = data.aws_iam_policy_document.tf_backend.json
}

resource "aws_iam_user_policy_attachment" "tf_backend" {
  user       = aws_iam_user.robot.name
  policy_arn = aws_iam_policy.tf_backend.arn
}

#########################
# Policy for ECR access #
#########################

data "aws_iam_policy_document" "ecr" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = [
      aws_ecr_repository.ui.arn,
      aws_ecr_repository.catalog.arn,
      aws_ecr_repository.cart.arn,
      aws_ecr_repository.checkout.arn,
      aws_ecr_repository.orders.arn,
    ]
  }
}

resource "aws_iam_policy" "ecr" {
  name        = "${aws_iam_user.robot.name}-ecr"
  description = "Allow user to manage ECR resources"
  policy      = data.aws_iam_policy_document.ecr.json
}

resource "aws_iam_user_policy_attachment" "ecr" {
  user       = aws_iam_user.robot.name
  policy_arn = aws_iam_policy.ecr.arn
}





###########################################################################
# Creating the necessary roles and groups for admin access to the cluster #
###########################################################################
# IAM Assume Role Policy Document
data "aws_iam_policy_document" "role_policy_eks_admins" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM Role Resource
resource "aws_iam_role" "eks_admins_role" {
  name               = "eks-admins-role"
  assume_role_policy = data.aws_iam_policy_document.role_policy_eks_admins.json
}




# Creating the group which will be allowed to assume the company-eks-admins role above
resource "aws_iam_group" "eks_admins" {
  name = "EKSAdmins"
}

# IAM Assume Role Policy Document for the group
data "aws_iam_policy_document" "assume_eks_admins" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    resources = [
      aws_iam_role.eks_admins_role.arn
    ]
  }
}

################ If and inline policy is needed instead of a normal policy
# resource "aws_iam_group_policy" "allow_assume_role" {
#   name   = "AllowAssumeCompanyEKSAdmins"
#   group  = aws_iam_group.eks_admins.name
#   policy = data.aws_iam_policy_document.assume_eks_admins.json
# }

resource "aws_iam_policy" "assume_eks_admins" {
  name        = "${aws_iam_group.eks_admins.name}-policy"
  description = "Policy that allows users to assume the eks_admins_role"
  policy      = data.aws_iam_policy_document.assume_eks_admins.json
}

resource "aws_iam_group_policy_attachment" "assume_eks_admins" {
  group      = aws_iam_group.eks_admins.name
  policy_arn = aws_iam_policy.assume_eks_admins.arn
}
