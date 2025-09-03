# 1. 创建 IAM 策略，允许 S3 访问
resource "aws_iam_policy" "s3_access_policy" {
  name        = var.policy_name
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

# 5. 获取现有EC2实例信息
data "aws_instance" "existing" {
  instance_id = var.ec2_instance_id
}

# 6. 使用null_resource或直接使用AWS CLI来附加IAM角色到现有实例
# 方法一：使用null_resource执行AWS CLI命令
resource "null_resource" "attach_iam_role" {
  triggers = {
    instance_id    = var.ec2_instance_id
    profile_name   = aws_iam_instance_profile.ec2_s3_profile.name
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ec2 associate-iam-instance-profile \
        --region ${var.aws_region} \
        --instance-id ${var.ec2_instance_id} \
        --iam-instance-profile Name=${aws_iam_instance_profile.ec2_s3_profile.name}
    EOT
  }

  depends_on = [
    aws_iam_instance_profile.ec2_s3_profile
  ]
}
  

