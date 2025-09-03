
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

data "aws_instance" "existing" {
  instance_id = var.ec2_instance_id
}

resource "aws_instance" "ec2_instance" {
  # 必须的参数
  ami           = data.aws_instance.existing.ami
  instance_type = data.aws_instance.existing.instance_type
  
  # 关键：只修改 IAM 实例配置文件
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  # 保持所有其他配置完全不变
  subnet_id              = data.aws_instance.existing.subnet_id
  vpc_security_group_ids = data.aws_instance.existing.vpc_security_group_ids
  key_name               = data.aws_instance.existing.key_name
  availability_zone      = data.aws_instance.existing.availability_zone

  # 保持原有标签
  tags = data.aws_instance.existing.tags

  # 非常重要的：忽略所有其他属性的变化
  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    aws_iam_instance_profile.ec2_s3_profile
  ]
}

