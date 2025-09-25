# Random ID to ensure global uniqueness
resource "random_id" "id" {
  byte_length = 4
}

# S3 Bucket
resource "aws_s3_bucket" "db_backups" {
  bucket = "interview-db-backups-${random_id.id.hex}"
}

# Disable public access blocks so the bucket can be public
resource "aws_s3_bucket_public_access_block" "disable_public_block" {
  bucket = aws_s3_bucket.db_backups.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Make bucket objects publicly readable
resource "aws_s3_bucket_acl" "db_backups_acl" {
  bucket = aws_s3_bucket.db_backups.id
  acl    = "public-read"
}

# Public bucket policy
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.db_backups.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.db_backups.arn,
          "${aws_s3_bucket.db_backups.arn}/*"
        ]
      }
    ]
  })
}
