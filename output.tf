output "load_balancer_dns_name" {
    value = aws_lb.default.dns_name
    description = "Load balancer dns name"
}
