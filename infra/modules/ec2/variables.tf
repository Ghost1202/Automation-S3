variable "name" {
  type        = string
  description = "Name prefix for EC2-related resources"
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

variable "subnet_id" {
  type        = string
  description = "Subnet ID where EC2 will be launched"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EC2 security group will be created"
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "Allowed CIDRs for SSH access"
}

variable "allocate_eip" {
  type        = bool
  description = "Whether to allocate an Elastic IP for the instance"
  default     = false
}

variable "user_data" {
  type        = string
  description = "Rendered user data script for the EC2 instance"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to EC2 resources"
  default     = {}
}
