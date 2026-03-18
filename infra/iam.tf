resource "aws_iam_role_policy" "ec2_backup_to_s3" {
  name = "${local.name}-ec2-backup-to-s3"
  role = module.app_ec2.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GetBucketLocation"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.db_backups.arn
      },
      {
        Sid    = "ListBackupPrefix"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.db_backups.arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${var.backup_prefix}/*"
            ]
          }
        }
      },
      {
        Sid    = "PutBackups"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.db_backups.arn}/${var.backup_prefix}/*"
      }
    ]
  })
}
