######commands#########
# terraform init
#terraform plan
# terraform apply
#terraform destroy

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
resource "aws_security_group" "secGroup" {
  name        = "secGroup"
  description = "Allow Http inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}
resource "aws_instance" "default" {
  ami = "ami-0889a44b331db0194"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.secGroup.id}"]
  # availability_zone = "us-east-1b"
  # associate_public_ip_address = true
  key_name = "defaultKeypair"
  user_data_replace_on_change = true
  user_data_base64 = "IyEvYmluL2Jhc2gNCnN1ZG8geXVtIHVwZGF0ZSAteQ0Kc3VkbyB5dW0gaW5zdGFsbCAteSBodHRwZA0Kc3VkbyBzeXN0ZW1jdGwgc3RhcnQgaHR0cGQNCnN1ZG8gc3lzdGVtY3RsIGVuYWJsZSBodHRwZA0Kc3VkbyB1c2VybW9kIC1hIC1HIGFwYWNoZSBlYzItdXNlcg0Kc3VkbyBjaG93biAtUiBlYzItdXNlcjphcGFjaGUgL3Zhci93d3cNCnN1ZG8gY2htb2QgMjc3NSAvdmFyL3d3dw0Kc3VkbyBmaW5kIC92YXIvd3d3IC10eXBlIGQgLWV4ZWMgY2htb2QgMjc3NSB7fSBcOw0Kc3VkbyBmaW5kIC92YXIvd3d3IC10eXBlIGYgLWV4ZWMgY2htb2QgMDY2NCB7fSBcOw0Kc3VkbyBlY2hvICI8P3BocCBwaHBpbmZvKCk7ID8+IiA+IC92YXIvd3d3L2h0bWwvcGhwaW5mby5waHA="

}
resource "aws_lb" "default" {

  name               = var.load_balancer_name
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.security_groud_id]
  subnets            = [for id in var.subnets_ids : id]

}
resource "aws_alb_target_group" "default" {
  name = var.aws_alb_target_group_name
  port = var.aws_alb_target_group_port
  protocol = var.aws_alb_target_group_protocol
  vpc_id = var.vpc_id
  health_check {
    interval = 30
    timeout = 5
    path = "/"
    unhealthy_threshold = 2
    healthy_threshold = 2
  }
  target_type = var.aws_alb_target_group_type

}
resource "aws_alb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port = var.aws_alb_listener_port
  protocol = var.aws_alb_listener_protocol
  default_action {
    target_group_arn = aws_alb_target_group.default.arn
    type = var.aws_alb_listener_default_action_type
  }
}resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_alb_target_group.default.arn
  target_id        = var.aws_lb_target_group_attachment_instance_id
  port = var.aws_lb_target_group_attachment_port
}

