##############################
# VPC Module
##############################
module "vpc" {
  source = "./modules/vpc"
}

##############################
# Security Groups Module
##############################
module "sg" {
  source          = "./modules/sg"
  vpc_id          = module.vpc.vpc_id
  bastion_sg_name = "bastion-sg"
}

##############################
# Application Load Balancer
# Targets private EC2s in ASG
##############################
module "alb" {
  source         = "./modules/alb"
  public_subnets = module.vpc.public_subnet_ids
  vpc_id         = module.vpc.vpc_id
  sg_id          = module.sg.alb_sg_id
}

##############################
# Auto Scaling Group
# Launches EC2s in private subnets
# Target group connects to ALB
##############################
module "asg" {
  source          = "./modules/asg"
  private_subnets = module.vpc.private_subnet_ids
  sg_id           = module.sg.private_sg_id
  instance_type   = "t2.small"
  key_name        = var.key_name
  target_group_arns = [
    module.alb.es_target_group_arn,
    module.alb.kibana_target_group_arn
  ]
}

##############################
# Bastion Host in Public Subnet
# Used for SSH access to private EC2s
##############################
module "bastion" {
  source        = "./modules/bastion"
  public_subnet = module.vpc.public_subnet_ids[0]
  sg_id         = module.sg.bastion_sg_id
  key_name      = var.key_name
}
