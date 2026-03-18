output "id" {
  value       = aws_instance.this.id
  description = "ID of EC2 instance"
}

output "public_ip" {
  value       = coalesce(try(aws_eip.this[0].public_ip, null), aws_instance.this.public_ip)
  description = "Public IP of EC2 instance"
}

output "iam_role_name" {
  value       = aws_iam_role.this.name
  description = "IAM role name attached to the EC2 instance"
}

output "instance_profile_name" {
  value       = aws_iam_instance_profile.this.name
  description = "Instance profile name attached to the EC2 instance"
}
