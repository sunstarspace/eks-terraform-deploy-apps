# Output for referencing in other modules
output "eks_admins_role_arn" {
  value = aws_iam_role.eks_admins_role.arn
}
