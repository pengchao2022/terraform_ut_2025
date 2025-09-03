terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "random" {}

# 生成随机密码
resource "random_password" "db_password" {
  length           = var.password_length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 将密码存储在AWS Secrets Manager中
resource "aws_secretsmanager_secret" "db_secret" {
  name = var.secret_name
  description = "Database credentials for ${var.db_name}"

  recovery_window_in_days = 0 # 设置为0表示立即删除，生产环境建议设置为7-30天

  tags = {
    Name = "${var.db_name}-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = var.db_engine
    host     = aws_db_instance.master.address
    port     = var.db_port
    dbname   = var.db_name
  })

  depends_on = [aws_db_instance.master]
}

# 创建RDS安全组
resource "aws_security_group" "rds_sg" {
  name        = var.rds_security_group_name
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 生产环境中应限制为特定IP范围
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.rds_security_group_name
  }
}

# 创建数据库子网组
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = var.db_subnet_group_name
  }
}

# 创建RDS主实例
resource "aws_db_instance" "master" {
  identifier              = "${var.db_name}-master"
  instance_class          = var.db_instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_type            = var.storage_type
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db_password.result # 使用随机生成的密码
  port                    = var.db_port
  multi_az                = false # 使用自定义多AZ部署
  availability_zone       = var.availability_zones[0] # 主实例在第一个可用区
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  skip_final_snapshot     = true # 生产环境中应设置为false并提供final_snapshot_identifier
  deletion_protection     = false # 生产环境中应设置为true

  tags = {
    Name = "${var.db_name}-master"
  }

  depends_on = [random_password.db_password]
}

# 创建第一个只读副本
resource "aws_db_instance" "replica_1" {
  identifier                = "${var.db_name}-replica-1"
  replicate_source_db       = aws_db_instance.master.identifier
  instance_class            = var.db_instance_class
  allocated_storage         = var.allocated_storage
  storage_type              = var.storage_type
  availability_zone         = var.availability_zones[1] # 第一个副本在第二个可用区
  vpc_security_group_ids    = [aws_security_group.rds_sg.id]
  skip_final_snapshot       = true
  backup_retention_period   = 0 # 副本不备份
  maintenance_window        = var.maintenance_window
  deletion_protection       = false

  tags = {
    Name = "${var.db_name}-replica-1"
  }

  depends_on = [aws_db_instance.master]
}

# 创建第二个只读副本
resource "aws_db_instance" "replica_2" {
  identifier                = "${var.db_name}-replica-2"
  replicate_source_db       = aws_db_instance.master.identifier
  instance_class            = var.db_instance_class
  allocated_storage         = var.allocated_storage
  storage_type              = var.storage_type
  availability_zone         = var.availability_zones[2] # 第二个副本在第三个可用区
  vpc_security_group_ids    = [aws_security_group.rds_sg.id]
  skip_final_snapshot       = true
  backup_retention_period   = 0 # 副本不备份
  maintenance_window        = var.maintenance_window
  deletion_protection       = false

  tags = {
    Name = "${var.db_name}-replica-2"
  }

  depends_on = [aws_db_instance.master]
}