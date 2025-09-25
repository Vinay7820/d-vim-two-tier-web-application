# ⚠️ Intentional Weakness: Public-readable storage bucket
resource "aws_s3_bucket" "db_backups" {
  bucket = "interview-db-backups-${random_id.id.hex}" # S3 bucket names must be globally unique
}

resource "aws_s3_bucket_acl" "db_backups_acl" {
  bucket = aws_s3_bucket.db_backups.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.db_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "db_backups_policy" {
  bucket = aws_s3_bucket.db_backups.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.db_backups.arn}/*"
      }
    ]
  })
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

resource "random_id" "id" {
  byte_length = 4
}
