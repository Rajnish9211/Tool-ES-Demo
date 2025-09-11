variable "public_subnet" {
  description = "The ID of the public subnet to launch the Bastion host in"
  type        = string
}

variable "sg_id" {
  description = "Security Group ID for the Bastion host"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 Key Pair to use"
  type        = string
}
