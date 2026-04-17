
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "AUY1105-duocapp-vpc"
  }
}

# CloudWatch Log Group para Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "vpc-flow-logs"
  retention_in_days = 7
}

# Flow Logs para la VPC
resource "aws_flow_log" "vpc_flow" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
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

resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "AUY1105-duocapp-subnet"
  }
}

resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.vpc.id
  description = "SG_para_AUY1105"

  ingress {
    description = "SSH_desde_IP_especifica"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["179.60.64.62/32"] # tu IPv4 real
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AUY1105-duocapp-sg"
  }
}

# IAM Role para EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "ec2" {
  ami                         = "ami-0fc5d935ebf8bc3bc"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_publica.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = false
  monitoring                  = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "AUY1105-duocapp-ec2"
  }
}
