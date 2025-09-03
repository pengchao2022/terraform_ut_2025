# 创建 EKS 集群（保持不变）
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = "1.27"

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

# 查找最新的 Ubuntu EKS 优化 AMI
data "aws_ami" "ubuntu_eks" {
  most_recent = true
  owners      = ["099720109477"] # Canonical 的官方账号

  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_${aws_eks_cluster.main.version}/node-*-20.04-amd64-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# 创建节点组的 IAM 角色（保持不变）
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# 附加必要的策略到节点角色（保持不变）
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# 创建启动模板（用于指定 Ubuntu AMI 和用户数据）
resource "aws_launch_template" "ubuntu_eks" {
  name_prefix   = "${var.cluster_name}-ubuntu-"
  image_id      = data.aws_ami.ubuntu_eks.id
  instance_type = "t3.medium"
  key_name      = var.key_name # 可选：用于 SSH 访问

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }

  # 用户数据 - Ubuntu 特定的引导脚本
  user_data = base64encode(<<-EOT
#!/bin/bash
set -ex
/etc/eks/bootstrap.sh ${var.cluster_name} \
  --apiserver-endpoint ${aws_eks_cluster.main.endpoint} \
  --b64-cluster-ca ${aws_eks_cluster.main.certificate_authority[0].data} \
  --container-runtime containerd
EOT
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.cluster_name}-ubuntu-node"
    }
  }

  # IAM 实例配置文件
  iam_instance_profile {
    name = aws_iam_instance_profile.node.name
  }
}

# 创建 IAM 实例配置文件
resource "aws_iam_instance_profile" "node" {
  name = "${var.cluster_name}-node-instance-profile"
  role = aws_iam_role.node.name
}

# 创建使用 Ubuntu 的节点组
resource "aws_eks_node_group" "ubuntu_nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "ubuntu-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  # 使用启动模板
  launch_template {
    id      = aws_launch_template.ubuntu_eks.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  # 更新策略
  update_config {
    max_unavailable = 1
  }

  # 标签
  labels = {
    os = "ubuntu"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_key_pair" "web_server_key" {
  key_name   = "eks-server-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/h331ZWQQggV5Pp78eQ18Qi3lOytWJhuGacssp5gTCmuIzmMfIW+t0fhDjWq6uda1t7NeYTh0zu5+36vkiy5s3Gr1M764X3qGKeGFmC7qe1kyF7RtVoZ4adufBgoNxtWi9zGmSBVi3G98YLhq0Tuj0mV9FT9l1F3NBOd3YbtCSWJ3Lx3WH9hMJ7eGAsBek8hatCtlDIFMQeF/xW4WBufWYkghjJE0G/Z9q4bJewrERD4B7GlDe+GGN8wAvehKKASySWgeeIwu+w6LYR7yzi+hyCCL+jyiycJ113u0gMo/oavdlFlVUeoJhmjsL46sjpgKPr2Yb0GhEVBOCW/rBXPFq+24zx/uds1PK/HtVNanr5kQBpJ4yT57hKhKhuNXWhJwuwQpzEFkwt36RqNFC/7CpH0BiRaafHDggBSnzPsNEECHnPnfgvzfcKoxMNcbbgYwZxNFEBD2Bjd11T1iS0aIxlO7RA2IMGl0Ch03lE3ztbiafRVIw6pTy09ehi7e+NE= pengchaoma@Pengchaos-MacBook-Pro.local" # 替换为您的公钥内容
}