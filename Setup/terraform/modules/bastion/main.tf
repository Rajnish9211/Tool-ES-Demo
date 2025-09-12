resource "aws_instance" "bastion" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.small"
  subnet_id     = var.public_subnet
  key_name      = var.key_name
  vpc_security_group_ids = [var.sg_id]

  tags = {
    Name = "bastion-host"
    Role = "Bastion"
    Project    = "ES-Kibana"
    monitoring = "false"
  }
}

output "public_ip" {
  value = aws_instance.bastion.public_ip
}


