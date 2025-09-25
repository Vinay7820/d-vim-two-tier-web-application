# K8s Cluster Security Group
resource "aws_security_group" "k8s_sg" {
  vpc_id = aws_vpc.interview_vpc.id
  ingress {
    from_port   = 27017 # MongoDB default port
    to_port     = 27017
    protocol    = "tcp"
    # Allow traffic from the K8s cluster to MongoDB
    security_groups = [aws_security_group.vm_sg.id]
  }
  # Additional ingress rules for the load balancer
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # You will need to set up ingress from the load balancer.
    # The load balancer's security group will be created by EKS/Kubernetes.
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "K8s Security Group"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
}

##################################################
# 1️⃣ Create IAM Role for EKS Cluster
##################################################
resource "aws_iam_role" "eks_role" {
  name = "interview-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach the EKS Cluster Policy
resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# (Optional) Attach additional policies if needed
resource "aws_iam_role_policy_attachment" "eks_vpc_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

##################################################
# 2️⃣ Create the EKS Cluster
##################################################
resource "aws_eks_cluster" "interview_k8s" {
  name     = "interview-cluster"
  role_arn = aws_iam_role.eks_role.arn

  version = "1.33"

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_a.id,
      aws_subnet.public_subnet_b.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy_attachment,
    aws_iam_role_policy_attachment.eks_vpc_attachment
  ]
}


# Node Group for K8s workers
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.interview_k8s.name
  node_role_arn   = "arn:aws:iam::150575195000:user/d-vim" # ⬅️ Replace with your EKS node IAM role ARN
  subnet_ids      = [aws_subnet.private_subnet.id]
  instance_types  = ["t2.medium"]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}
