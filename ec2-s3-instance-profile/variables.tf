variable "aws_region" {
  description = "AWS 区域"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "要访问的 S3 存储桶名称"
  type        = string
  validation {
    condition     = length(var.bucket_name) > 0
    error_message = "存储桶名称不能为空。"
  }
}

variable "ec2_instance_id" {
  description = "已存在的 EC2 实例 ID"
  type        = string
  validation {
    condition     = can(regex("^i-([a-z0-9]{8}|[a-z0-9]{17})$", var.ec2_instance_id))
    error_message = "实例 ID 格式不正确。"
  }
}

variable "role_name" {
  description = "IAM 角色名称"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "policy_name" {
  description = "IAM 策略名称"
  type        = string
  default     = "EC2S3AccessPolicy"
}

variable "instance_profile_name" {
  description = "实例配置文件名称"
  type        = string
  default     = "EC2S3InstanceProfile"
}

variable "s3_actions" {
  description = "允许的 S3 操作列表"
  type        = list(string)
  default     = ["s3:GetObject", "s3:PutObject", "s3:ListBucket", "s3:DeleteObject"]
}

variable "tags" {
  description = "要应用到资源的标签"
  type        = map(string)
  default     = {
    Terraform   = "true"
    Environment = "production"
  }
}