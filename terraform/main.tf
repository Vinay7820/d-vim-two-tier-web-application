# Terraform AWS Infrastructure
provider "aws" {
  region = "us-east-1"
}

# Example VPC (insecure setup, intentionally simplified)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Add more resources (subnets, EC2, EKS, S3) here
