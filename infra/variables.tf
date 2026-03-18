variable "aws_region" {
  type        = string
  description = "AWS region for all resources"
  default     = "eu-central-1"
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "List of CIDRs allowed to SSH into EC2 instances"
}

variable "ami" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair to use"
}

variable "allocate_eip" {
  type        = bool
  description = "Whether to allocate Elastic IP for the instance"
  default     = false
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to all resources"
  default     = {}
}

variable "zone_name" {
  type        = string
  description = "Public Route53 hosted zone name, for example example.com"
}

variable "fqdn" {
  type        = string
  description = "Fully qualified domain name for DNS record, for example app.example.com"
}

variable "backup_bucket_name" {
  type        = string
  description = "S3 bucket name for MongoDB backups"
}

variable "backup_prefix" {
  type        = string
  description = "S3 prefix used for stored backups"
  default     = "backups"
}

variable "backup_transition_days" {
  type        = number
  description = "Number of days before backups transition to Glacier"
  default     = 7
}

variable "backup_expiration_days" {
  type        = number
  description = "Number of days before backups are deleted"
  default     = 30
}

variable "mongo_container_name" {
  type        = string
  description = "MongoDB container name from docker-compose"
  default     = "go-todo-mongo"
}

variable "mongo_db_name" {
  type        = string
  description = "MongoDB database name to dump"
  default     = "todo"
}
