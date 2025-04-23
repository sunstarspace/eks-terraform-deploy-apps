variable "tfstate_bucket" {
  description = "The S3 bucket in AWS for storing TF state"
  default     = "eks-sunstar-apps-tfstate"
}

variable "tfstate_lock_table" {
  description = "The DynamoDB table for TF state locking"
  default     = "eks-sunstar-apps-tfstate-lock"
}

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
