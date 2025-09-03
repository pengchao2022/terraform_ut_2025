provider "aws" {
  region = var.aws_region
}

# 1. 创建 IAM 策略，允许 S3 访问
resource "aws_iam_policy" "s3_access_policy" {
  name        = var.policy_name
  description = "允许 EC2 实例访问 S3 存储桶 ${var.bucket_name}"
  tags        = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.s3_actions
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

# 2. 创建 IAM 角色
resource "aws_iam_role" "ec2_s3_role" {
  name               = var.role_name
  description        = "允许 EC2 实例访问 S3 的角色"
  tags               = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 3. 将策略附加到角色
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# 4. 创建实例配置文件
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.ec2_s3_role.name
  tags = var.tags
}

# 5. 将实例配置文件附加到已存在的 EC2 实例
resource "aws_iam_instance_profile_attachment" "ec2_attachment" {
  instance_id        = var.ec2_instance_id
  instance_profile_id = aws_iam_instance_profile.ec2_s3_profile.id
}