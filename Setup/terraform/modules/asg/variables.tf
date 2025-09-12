variable "private_subnets" {
  description = "List of private subnet IDs for the ASG"
  type        = list(string)
}

variable "sg_id" {
  description = "Security group ID for EC2 in private subnets"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for ASG"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "target_group_arns" {
  description = "List of target group ARNs for the ALB"
  type        = list(string)
}