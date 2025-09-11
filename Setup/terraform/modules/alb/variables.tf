variable "public_subnets" {}
variable "vpc_id" {}
variable "sg_id" {} 
variable "target_group_port" {
  default = 9200       
}

