output "alb_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "es_target_group_arn" {
  description = "Target group ARN for Elasticsearch (9200)"
  value       = aws_lb_target_group.es_tg.arn
}

output "kibana_target_group_arn" {
  description = "Target group ARN for Kibana (5601)"
  value       = aws_lb_target_group.kibana_tg.arn
}
