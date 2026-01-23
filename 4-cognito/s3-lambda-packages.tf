# S3 Bucket para armazenar pacotes Lambda
resource "aws_s3_bucket" "lambda_packages" {
  bucket = "${var.project_name}-lambda-packages-new-${var.environment}"

  tags = {
    Name        = "${var.project_name}-lambda-packages-new-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Versionamento do bucket
resource "aws_s3_bucket_versioning" "lambda_packages" {
  bucket = aws_s3_bucket.lambda_packages.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Criptografia do bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_packages" {
  bucket = aws_s3_bucket.lambda_packages.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquear acesso público
resource "aws_s3_bucket_public_access_block" "lambda_packages" {
  bucket = aws_s3_bucket.lambda_packages.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy para versões antigas
resource "aws_s3_bucket_lifecycle_configuration" "lambda_packages" {
  bucket = aws_s3_bucket.lambda_packages.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}