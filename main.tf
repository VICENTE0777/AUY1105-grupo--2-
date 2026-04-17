provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "AUY1105-duocapp-vpc"
  }
}

# Flow Logs para la VPC
resource "aws_flow_log" "vpc_flow" {
  log_destination_type = "cloud-watch-logs"
  log_group_name       = "vpc-flow-logs"
  iam_role_arn         = aws_iam_role.vpc_flow_role.arn
  vpc_id               = aws_vpc.vpc.id
}

resource "aws_iam_role" "vpc_flow_role" {
  name = "vpc-flow-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

# Security Group por defecto restringido
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress = []
  egress  = []
}

resource "aws_subnet" "sub