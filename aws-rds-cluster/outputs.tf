output "rds_master_endpoint" {
  description = "主数据库实例端点"
  value       = aws_db_instance.master.endpoint
}

output "rds_replica_1_endpoint" {
  description = "第一个只读副本端点"
  value       = aws_db_instance.replica_1.endpoint
}

output "rds_replica_2_endpoint" {
  description = "第二个只读副本端点"
  value       = aws_db_instance.replica_2.endpoint
}

output "rds_security_group_id" {
  description = "RDS安全组ID"
  value       = aws_security_group.rds_sg.id
}

output "db_subnet_group_id" {
  description = "数据库子网组ID"
  value       = aws_db_subnet_group.db_subnet_group.id
}

output "db_secret_arn" {
  description = "数据库密码在Secrets Manager中的ARN"
  value       = aws_secretsmanager_secret.db_secret.arn
}

output "db_secret_name" {
  description = "数据库密码在Secrets Manager中的名称"
  value       = aws_secretsmanager_secret.db_secret.name
}

# 敏感输出，在生产环境中可能需要谨慎使用
output "generated_db_password" {
  description = "生成的数据库密码（敏感信息）"
  value       = random_password.db_password.result
  sensitive   = true
}