
variable "vpc_id" {
  
    type = string
    description = "Vpc id"
}

variable "region" {

    type = string
    description = "AWS Region"
    default = "us-east-1"
}

variable "profile" {

    type = string
    description = "AWS Profile"
    default = "default"
}
variable "vpc_id" {

    type = string
    description = "Vpc id"
  
}

variable "load_balancer_name" {
  
  type = string
  description = "load balancer name"
  default = "default"

}

variable "load_balancer_type" {

    type = string
    description = "load balancer type"
    default = "application"
}

variable "security_groud_id" {

    type = string
    description = "Security group name"
}

variable "subnets_ids" {

    type = list(string)
    description = "Subnets ids list"
}

variable "aws_alb_target_group_name" {

    type = string
    description = "application load balancer target group name"
    default = "my-alb-target-group"
}

variable "aws_alb_target_group_port" {

    type = number
    description = "application load balancer target group name"
    default = 80
}

variable "aws_alb_target_group_protocol" {

    type = string
    description = "application load balancer target group protocol"
    default = "HTTP"
}

variable "aws_alb_target_group_type" {

    type = string
    description = "application load balancer target group type"
    default = "instance"
}

variable "aws_alb_listener_port" {

    type = number
    description = "application load balancer listener port type"
    default = 80
}


variable "aws_alb_listener_protocol" {

    type = string
    description = "application load balancer listener protocol"
    default = "HTTP"
}


variable "aws_alb_listener_default_action_type" {

    type = string
    description = "application load balancer listener default action type"
    default = "forward"
}

variable "aws_lb_target_group_attachment_port" {

    type = number
    description = "application load balancer attachement port"
    default = 80
}

variable "aws_lb_target_group_attachment_instance_id" {

    type = string
    description = "application load balancer attachement instance id"
}



