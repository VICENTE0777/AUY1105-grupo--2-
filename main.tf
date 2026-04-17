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

# Subred pública (SIN IP pública automática)
resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "AUY1105-duocapp-subnet-publica"
  }
}

# Security Group seguro
resource "aws_security_group" "sg" {
  name        = "AUY1105-duocapp-sg"
  description = "Security group para acceso SSH restringido"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["179.60.64.62/32"]
  }

  # 🔐 Egress restringido (NO todo abierto)
  egress {
    description = "Allow HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AUY1105-duocapp-sg"
  }
}

# EC2 SIN IP pública
resource "aws_instance" "ec2" {
  ami                         = "ami-0fc5d935ebf8bc3bc"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_publica.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "AUY1105-duocapp-ec2"
  }
}