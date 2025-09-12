resource "aws_lb" "alb" {
  name               = "app-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.public_subnets

  tags = {
    Name = "AppLoadBalancer"
  }
}

# Target Group for Elasticsearch (9200)
resource "aws_lb_target_group" "es_tg" {
  name        = "es-target-group"
  port        = 9200
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    port                = "9200"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "ElasticsearchTargetGroup"
  }
}

# Target Group for Kibana (5601)
resource "aws_lb_target_group" "kibana_tg" {
  name        = "kibana-target-group"
  port        = 5601
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/status"
    port                = "5601"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "KibanaTargetGroup"
  }
}

# Listener for Elasticsearch (9200)
resource "aws_lb_listener" "es_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 9200
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.es_tg.arn
  }
}

# Listener for Kibana (5601)
resource "aws_lb_listener" "kibana_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 5601
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kibana_tg.arn
  }
}