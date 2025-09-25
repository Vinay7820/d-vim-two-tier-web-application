# ⚠️ Intentional Weakness: Overly Permissive IAM Role
resource "aws_iam_role" "overly_permissive_role" {
  name = "OverlyPermissiveRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "admin_policy" {
  name = "AdminPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "*"
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_admin_policy" {
  role       = aws_iam_role.overly_permissive_role.name
  policy_arn = aws_iam_policy.admin_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "InstanceProfile"
  role = aws_iam_role.overly_permissive_role.name
}

# Security Group for the VM
resource "aws_security_group" "vm_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Intentional Weakness: Public SSH
    description = "Allow SSH from the internet"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "VM Security Group"
  }
}

# The VM
resource "aws_instance" "mongodb_vm" {
  # ⚠️ Intentional Weakness: Use an AMI that is 1+ year outdated
  ami           = "ami-0dba2cb6798e1d3c5" # ⬅️ Replace with an outdated AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.vm_sg.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  
  # A simple script to install an outdated MongoDB
  user_data = <<-EOT
              #!/bin/bash
              sudo apt-get update
              # ⚠️ Intentional Weakness: Install a 1+ year outdated MongoDB version
              # You need to find the specific install commands for an older version
              # For example, by specifying a version in the package manager.
              EOT

  tags = {
    Name = "MongoDB VM"
  }
}
