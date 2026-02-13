resource "aws_iam_policy" "backup_policy" {
  name = "ec2-s3-backup-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.backups.arn,
          "${aws_s3_bucket.backups.arn}/*"
        ]
      }
    ]
  })
}


#IAM Role

resource "aws_iam_role" "ec2_backup_role" {
  name = "ec2-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

#Attach policy

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_backup_role.name
  policy_arn = aws_iam_policy.backup_policy.arn
}

#Instance profile

resource "aws_iam_instance_profile" "profile" {
  name = "ec2-backup-profile"
  role = aws_iam_role.ec2_backup_role.name
}
