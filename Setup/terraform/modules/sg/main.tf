# ─────────────────────────────────────────────────────────────
# Bastion Host Security Group
# Allows SSH from the internet (default 0.0.0.0/0, configurable)
# ─────────────────────────────────────────────────────────────

resource "aws_security_group" "bastion" {
  name        = var.bastion_sg_name
  description = "Allow SSH access to Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ssh_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# ─────────────────────────────────────────────────────────────
# Private EC2 Security Group
# Allows SSH only from Bastion SG, Elasticsearch access within VPC
# ─────────────────────────────────────────────────────────────

resource "aws_security_group" "private" {
  name        = "private-ec2-sg"
  description = "Private EC2 SG - allows SSH from Bastion and port 9200 from VPC"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description = "Elasticsearch traffic within VPC"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Adjust if VPC CIDR is different
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-ec2-sg"
  }
}

# ─────────────────────────────────────────────────────────────
# ALB Security Group
# Public HTTP access on port 80
# ─────────────────────────────────────────────────────────────

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "ALB SG - allow HTTP access from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}
