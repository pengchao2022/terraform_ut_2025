# terraform.tfvars
ec2_instance_id = "i-083ccca081df0a231"
policy_name = "awsdevopsec2policy"
role_name = "aws-devops-ec2-s3-role"
instance_profile_name = "awsyiming-ec2-s3-profile"
bucket_name = "pythongotos3presign2020"
s3_actions = ["s3:GetObject", "s3:ListBucket"]
tags = {
  Environment = "production"
  Project     = "terraform-IaC-project"
}