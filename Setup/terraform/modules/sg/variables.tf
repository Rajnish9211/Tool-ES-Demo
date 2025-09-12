variable "vpc_id" {
  description = "The VPC ID where security groups will be created"
  type        = string
}

variable "bastion_sg_name" {
  description = "Name for the Bastion Host security group"
  type        = string
}

variable "bastion_ssh_cidr" {
  description = "CIDR allowed to SSH into bastion"
  type        = string
  default     = "0.0.0.0/0"
}