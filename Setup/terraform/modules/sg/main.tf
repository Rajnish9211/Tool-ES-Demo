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
# Allows SSH from Bastion, ES (9200) and Kibana (5601) only via ALB
# ─────────────────────────────────────────────────────────────

resource "aws_security_group" "private" {
  name        = "private-ec2-sg"
  description = "Private EC2 SG - allows SSH from Bastion, ES & Kibana only from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "Elasticsearch traffic from ALB"
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Kibana traffic from ALB"
    from_port       = 5601
    to_port         = 5601
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
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
# Public access on 80, 9200, and 5601
# ─────────────────────────────────────────────────────────────

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "ALB SG - allow HTTP, ES & Kibana access from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Elasticsearch public access via ALB"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kibana public access via ALB"
    from_port   = 5601
    to_port     = 5601
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