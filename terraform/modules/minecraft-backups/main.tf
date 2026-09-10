# ---------------------------------------------------------
# S3 BACKUP BUCKET
# ---------------------------------------------------------

resource "aws_s3_bucket" "this" {
  bucket_prefix = "${var.NAME}-minecraft-backups-"

  tags = var.TAGS
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-minecraft-backups"
    status = "Enabled"

    filter {
      prefix = "backups/"
    }

    expiration {
      days = var.RETENTION_DAYS
    }

    noncurrent_version_expiration {
      noncurrent_days = var.RETENTION_DAYS
    }
  }
}

# ---------------------------------------------------------
# BACKUP POD IAM ROLE
# ---------------------------------------------------------

resource "aws_iam_role" "this" {
  name = "${var.NAME}-minecraft-backups"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = var.TAGS
}

# ---------------------------------------------------------
# S3 BACKUP PERMISSIONS
# ---------------------------------------------------------

resource "aws_iam_role_policy" "this" {
  name = "${var.NAME}-minecraft-backups"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.this.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.this.arn}/backups/*"
      }
    ]
  })
}

# ---------------------------------------------------------
# EKS POD IDENTITY
# ---------------------------------------------------------

resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.CLUSTER_NAME
  namespace       = var.NAMESPACE
  service_account = var.SERVICE_ACCOUNT_NAME
  role_arn        = aws_iam_role.this.arn
}