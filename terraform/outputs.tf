output "load_balancer_endpoint" {
  description = "The endpoint of the Kubernetes load balancer."
  # This output will depend on the Ingress resource you define in your
  # Kubernetes YAML manifests, which is created after Terraform runs.
  # You'll need to define it in your K8s manifest and retrieve it with kubectl.
  value = "Check your Kubernetes Ingress for the endpoint"
}

output "mongodb_vm_public_ip" {
  description = "The public IP address of the MongoDB VM."
  value       = aws_instance.mongodb_vm.public_ip
}

output "storage_bucket_name" {
  description = "The name of the public-readable storage bucket."
  value       = aws_s3_bucket.db_backups.bucket
}
