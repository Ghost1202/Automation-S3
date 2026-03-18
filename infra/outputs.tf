output "ec2_id" {
  value       = module.app_ec2.id
  description = "ID of EC2 instance"
}

output "ec2_public_ip" {
  value       = module.app_ec2.public_ip
  description = "Public IP of EC2 instance"
}

output "ec2_iam_role_name" {
  value       = module.app_ec2.iam_role_name
  description = "IAM role name attached to the EC2 instance"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "IDs of public subnets"
}

output "backup_bucket_name" {
  value       = aws_s3_bucket.db_backups.bucket
  description = "Name of the S3 bucket used for database backups"
}
