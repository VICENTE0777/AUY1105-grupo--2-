terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "AUY1105-duocapp-vpc"
  }
}

# Subred pública
resource "aws_subnet" "subnet_publica" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "AUY1105-duocapp-subnet-publica"
  }
}

# Security Group (solo SSH permitido desde tu IP)
resource "aws_security_group" "sg" {
  name   = "AUY1105-duocapp-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["179.60.64.62/32"]
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

# EC2 Ubuntu 24.04 LTS
resource "aws_instance" "ec2" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_publica.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "AUY1105-duocapp-ec2"
  }
}