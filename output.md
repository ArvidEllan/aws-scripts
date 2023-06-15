output "load_balancer_name" {
  
  value = module.load_balancer.load_balancer_dns_name
  description = "Load balancer dns name"
}
