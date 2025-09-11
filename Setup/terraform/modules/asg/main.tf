# -----------------------------------------
# IAM Role & Instance Profile for SSM
# -----------------------------------------
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssm_role" {
  name               = "ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# -----------------------------------------
# Launch Template for EC2 in Private Subnets
# -----------------------------------------
resource "aws_launch_template" "lt" {
  name_prefix            = "private-ec2-"
  image_id               = "ami-07f07a6e1060cd2a8" # Ubuntu 22.04 LTS (ap-south-1)
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.sg_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get upgrade -y
    apt-get install -y openjdk-17-jdk python3 python3-pip git unzip
    pip3 install --upgrade pip boto3 botocore

    snap install amazon-ssm-agent --classic
    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
    systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

    echo "SSM Agent installed on $(hostname)" > /var/log/ssm-install.log
    echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" >> /var/log/ssm-install.log
    echo "ASG Name: private-asg" >> /var/log/ssm-install.log
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name       = "asg-instance"
      monitoring = "true"
    }
  }
}

# -----------------------------------------
# Auto Scaling Group
# -----------------------------------------
resource "aws_autoscaling_group" "asg" {
  name                      = "private-asg"
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 5
  vpc_zone_identifier       = var.private_subnets
  health_check_type         = "EC2"
  health_check_grace_period = 120
  target_group_arns         = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  termination_policies = ["OldestInstance"]
}
