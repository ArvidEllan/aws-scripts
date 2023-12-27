
provider "aws" {
  region = "us-east-1"  # Set your desired region
}

resource "aws_vpc" "my_vpc" {
  cidr_block        = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "my_internet_gateway" {}

resource "aws_vpc_attachment" "attach_gateway" {
  vpc_id             = aws_vpc.my_vpc.id
  internet_gateway_id = aws_internet_gateway.my_internet_gateway.id
}

resource "aws_security_group" "my_security_group" {
  name_prefix        = "my-security-group-"
  description        = "Enable HTTP and SSH access"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_api_gateway_rest_api" "my_api_gateway" {
  name = "MyAPIGateway"
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.my_api_gateway.root_resource_id
  path_part   = "myresource"
}

resource "aws_api_gateway_method" "my_method" {
  http_method  = "ANY"  # Allow any HTTP method
  resource_id  = aws_api_gateway_resource.my_resource.id
  rest_api_id  = aws_api_gateway_rest_api.my_api_gateway.id

  request_parameters = {
    "method.request.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_settings" "my_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  stage_name = "default"
  method_path = aws_api_gateway_resource.my_resource.path_part
  settings = {
    metrics_enabled = true
    logging_level  = "INFO"
    data_trace_enabled = true
    throttling_burst_limit = 5000
    throttling_rate_limit = 10000
  }
}

resource "aws_api_gateway_method_response" "my_method_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id = aws_api_gateway_resource.my_resource.id
  http_method = aws_api_gateway_method.my_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id = aws_api_gateway_resource.my_resource.id
  http_method = aws_api_gateway_method.my_method.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"  # Proxy any HTTP method
  uri                     = "http://"  # Replace with your actual endpoint

  request_parameters = {
    "integration.request.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "my_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id = aws_api_gateway_resource.my_resource.id
  http_method = aws_api_gateway_method.my_method.http_method
  status_code = aws_api_gateway_method_response.my_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}
