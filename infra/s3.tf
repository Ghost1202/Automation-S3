resource "aws_s3_bucket" "db_backups" {
  bucket = var.backup_bucket_name

  tags = merge(
    {
      Name = "${local.name}-db-backups"
    },
    var.tags
  )
}

resource "aws_s3_bucket_public_access_block" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  rule {
    id     = "db-backup-retention"
    status = "Enabled"

    filter {
      prefix = "${var.backup_prefix}/"
    }

    transition {
      days          = var.backup_transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.backup_expiration_days
    }
  }
}
