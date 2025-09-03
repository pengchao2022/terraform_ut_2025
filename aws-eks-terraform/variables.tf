variable "vpc_id" {
  description = "VPC ID where EKS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "key_name" {
  description = "SSH key pair name for EC2 instances"
  type        = string
  default     = "" # 如果不需要 SSH 访问，可以留空
}