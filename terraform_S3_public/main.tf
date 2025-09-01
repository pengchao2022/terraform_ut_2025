provider "aws" {
  region = "us-east-1"  # 可以根据需要修改区域
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "mys3publicaccessbucket007abcyt"
  
  tags = {
    Name        = "My Public Access Bucket"
    Environment = "Test"
  }
}

# 禁用默认的阻止公共访问策略
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

# 设置桶策略允许公共读取访问
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

data "aws_iam_policy_document" "public_read" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.public_bucket.arn}/*"]
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.public_bucket.arn]
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}


# 输出信息
output "bucket_name" {
  value = aws_s3_bucket.public_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.public_bucket.arn
}