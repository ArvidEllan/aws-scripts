# Define provider and AWS region
provider "aws" {
  region = "us-west-2"
}

# Create VPC
resource "aws_vpc" "databricks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "databricks-vpc"
  }
}

# Create Subnet
resource "aws_subnet" "databricks_subnet" {
  vpc_id                  = aws_vpc.databricks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  tags = {
    Name = "databricks-subnet"
  }
}

# Create Security Group
resource "aws_security_group" "databricks_sg" {
  vpc_id = aws_vpc.databricks_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "databricks-sg"
  }
}

# Create IAM Role for Databricks
resource "aws_iam_role" "databricks_role" {
  name = "databricks-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "databricks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policies to IAM Role
resource "aws_iam_policy_attachment" "databricks_policy_attachment" {
  name       = "databricks-policy-attachment"
  roles      = [aws_iam_role.databricks_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDatabricksServiceRole"
}

# Provision Databricks environment
resource "databricks_workspace" "databricks_environment" {
  name             = "my-databricks-environment"
  location         = "s3://my-databricks-bucket"
  subnet_id        = aws_subnet.databricks_subnet.id
  vpc_id           = aws_vpc.databricks_vpc.id
  security_group_id = aws_security_group.databricks_sg.id
  iam_role         = aws_iam_role.databricks_role.name
}
