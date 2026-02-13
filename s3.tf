resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "backups" {
  bucket = "${var.project_name}-${random_id.suffix.hex}"

  tags = {
    Name = "db-backups"
  }
}


#This is lifecycle

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "backup-rotation"
    status = "Enabled"

    filter {}
    transition {
      days          = 7
      storage_class = "GLACIER"
    }

    expiration {
      days = 30
    }
  }
}
