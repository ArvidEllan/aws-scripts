# myvpc variables
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
  type        = string
}

# public subnet AZ1 cidr block
variable "public_subnet_az1_cidr" {
  default     = "10.0.0.0/24"
  description = "CIDR block for the public subnet in AZ1"
  type        = string
}

# public subnet AZ2 cidr block
variable "public_subnet_az2_cidr" {
  default     = "10.0.1.0/24"
  description = "CIDR block for the public subnet in AZ2"
  type        = string
}

# private app subnet AZ1 cidr block
variable "private_app_subnet_az1_cidr" {
  default     = "10.0.2.0/24"
  description = "CIDR block for the private app subnet in AZ1"
  type        = string
} 

# private app subnet AZ2 cidr block
variable "private_app_subnet_az2_cidr" {
  default     = "10.0.3.0/24"
  description = "CIDR block for the private app subnet in AZ2"
  type        = string
} 

# private data subnet AZ1 cidr block
variable "private_data_subnet_az1_cidr" {
  default     = "10.0.4.0/24"
  description = "CIDR block for the private data subnet in AZ1"
  type        = string
} 

# private data subnet AZ2 cidr block
variable "private_data_subnet_az2_cidr" {
  default     = "10.0.5.0/24"
  description = "CIDR block for the private data subnet in AZ2"
  type        = string
} 
