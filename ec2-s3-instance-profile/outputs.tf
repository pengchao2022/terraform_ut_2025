output "iam_role_arn" {
  description = "创建的 IAM 角色 ARN"
  value       = aws_iam_role.ec2_s3_role.arn
}

output "iam_policy_arn" {
  description = "创建的 IAM 策略 ARN"
  value       = aws_iam_policy.s3_access_policy.arn
}

output "instance_profile_name" {
  description = "创建的实例配置文件名称"
  value       = aws_iam_instance_profile.ec2_s3_profile.name
}

output "instance_profile_association_id" {
  description = "实例配置文件关联 ID"
  value       = aws_iam_instance_profile_association.ec2_association.id
}

output "ec2_instance_id" {
  description = "目标 EC2 实例 ID"
  value       = var.ec2_instance_id
}

output "s3_bucket_name" {
  description = "允许访问的 S3 存储桶名称"
  value       = var.bucket_name
}