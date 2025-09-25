resource "random_id" "id" {
  byte_length = 4
}

resource "aws_s3_bucket" "db_backups" {
  bucket = "interview-db-backups-${random_id.id.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "disable_public_block" {
  bucket = aws_s3_bucket.db_backups.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

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
