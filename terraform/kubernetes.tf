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

# Managed Kubernetes Cluster
resource "aws_eks_cluster" "interview_k8s" {
  name     = "interview-cluster"
  role_arn = "arn:aws:iam::150575195000:user/d-vim" # ⬅️ Replace with your EKS IAM role ARN
  vpc_config {
    subnet_ids = [aws_subnet.private_subnet.id]
  }
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
