terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Última versión mayor estable
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "AUY1105-duocapp-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "AUY1105-duocapp-vpc"
  }
}

# Subred pública
resource "aws_subnet" "AUY1105-duocapp-subnet-publica" {
  vpc_id            = aws_vpc.AUY1105-duocapp-vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "AUY1105-duocapp-subnet-publica"
  }
}

# Security Group (solo SSH permitido)
resource "aws_security_group" "AUY1105-duocapp-sg" {
  vpc_id = aws_vpc.AUY1105-duocapp-vpc.id
  name   = "AUY1105-duocapp-sg"

  ingress {
    description = "SSH desde IP específica"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["X.X.X.X/32"] # Reemplazar con tu IP
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

# Instancia EC2 Ubuntu 24.04 LTS
resource "aws_instance" "AUY1105-duocapp-ec2" {
  ami           = "ami-0fc5d935ebf8bc3bc" # Ubuntu 24.04 LTS en us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.AUY1105-duocapp-subnet-publica.id
  vpc_security_group_ids = [aws_security_group.AUY1105-duocapp-sg.id]

  tags = {
    Name = "AUY1105-duocapp-ec2"
  }
}
