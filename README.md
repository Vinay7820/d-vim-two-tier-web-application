# Vulnerable Two-Tier Web Application (AWS)

This repository contains an intentionally misconfigured two-tier web application environment for interview/demo purposes.

## Components

### 1. Infrastructure (Terraform)
- Deploys:
  - VPC & Subnets
  - EC2 VM with outdated MongoDB
  - S3 bucket for database backups (publicly readable)
  - EKS Cluster for the containerized app

### 2. Web Application (Docker + K8s)
- Simple Node.js app (Tasky) connecting to MongoDB
- Container image includes `wizexercise.txt` with your name
- Deployed on Kubernetes with:
  - Cluster-wide `cluster-admin` role
  - Ingress exposed via AWS Load Balancer

### 3. MongoDB VM
- EC2 instance running outdated Ubuntu & MongoDB
- SSH exposed to the public internet
- Overly permissive IAM role (able to create VMs)
- Database restricted to K8s network with authentication enabled
- Daily backup to S3 bucket (publicly readable + listable)

### 4. CI/CD Pipelines (GitHub Actions)
- **iac.yml** → Deploys infrastructure with Terraform
- **app.yml** → Builds Docker image, pushes to ECR, applies K8s manifests

### 5. Security Controls (to be demonstrated)
- AWS CloudTrail enabled for audit logging
- AWS Config / Security Hub to detect misconfigurations
- GuardDuty for threat detection

## How to Use

### Step 1: Terraform (Infrastructure)
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### Step 2: VM Setup (MongoDB)
- SSH into the created EC2 VM
```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```
- Run setup script
```bash
bash vm/mongo_install.sh
```

### Step 3: Build & Push Docker App
```bash
cd docker-app
docker build -t <ECR_REPO>:latest .
docker push <ECR_REPO>:latest
```

### Step 4: Deploy App on K8s
```bash
kubectl apply -f k8s/
```

### Step 5: Verify
- Access the web app via Load Balancer / Ingress URL
- Insert data via app and confirm it appears in MongoDB
- Check S3 bucket for daily backups

## Demo Checklist
1. Show **repo in GitHub** with pipelines
2. Run **Terraform pipeline** → proves infra deploys
3. Run **App pipeline** → builds & pushes container
4. `kubectl get pods` → show container running
5. `kubectl exec` → confirm `wizexercise.txt` exists in container
6. Open web app → prove DB connection works
7. Show **S3 bucket** with public backup files
8. Open **Security Hub / Config / GuardDuty** → show misconfigurations detected
9. Wrap up with risks + how Wiz/security tools mitigate

## Intentional Weaknesses
- Public SSH access on VM
- Outdated MongoDB version
- Overly permissive IAM role
- Publicly readable S3 bucket
- Cluster-admin rights to app pod

---

⚠️ **Disclaimer:** This repo is intentionally insecure and must NOT be used in production.
