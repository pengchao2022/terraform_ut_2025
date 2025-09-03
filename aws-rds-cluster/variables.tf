variable "region" {
  description = "AWS区域"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "已存在的VPC ID"
  type        = string
}

variable "db_subnet_group_name" {
  description = "数据库子网组名称"
  type        = string
}

variable "db_subnet_ids" {
  description = "数据库子网ID列表"
  type        = list(string)
}

variable "db_instance_class" {
  description = "数据库实例类型"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine" {
  description = "数据库引擎"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "数据库引擎版本"
  type        = string
  default     = "8.0"
}

variable "db_name" {
  description = "数据库名称"
  type        = string
}

variable "db_username" {
  description = "数据库主用户名"
  type        = string
}

variable "db_port" {
  description = "数据库端口"
  type        = number
  default     = 3306
}

variable "maintenance_window" {
  description = "维护窗口"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  description = "备份窗口"
  type        = string
  default     = "03:00-06:00"
}

variable "backup_retention_period" {
  description = "备份保留期"
  type        = number
  default     = 7
}

variable "storage_type" {
  description = "存储类型"
  type        = string
  default     = "gp2"
}

variable "allocated_storage" {
  description = "分配的存储空间(GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "最大分配的存储空间(GB)"
  type        = number
  default     = 100
}

variable "rds_security_group_name" {
  description = "RDS安全组名称"
  type        = string
  default     = "rds-security-group"
}

variable "availability_zones" {
  description = "可用区列表"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "secret_name" {
  description = "Secrets Manager中的密码名称"
  type        = string
  default     = "rds-db-password"
}

variable "password_length" {
  description = "密码长度"
  type        = number
  default     = 16
}