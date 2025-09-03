aws_region          = "us-east-1"
bucket_name         = "s3eastusiloveyou2000"
ec2_instance_id     = "i-0f170df4d5e821418"
role_name           = "Ec2S3Role"
policy_name         = "Ec2S3AccessPolicy"
instance_profile_name = "Oms-Ec2-Instance-profile"

tags = {
  Environment = "production"
  Project     = "OMS orders"
  Owner       = "devops-Yiming"
}
