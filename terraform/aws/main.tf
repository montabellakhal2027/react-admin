provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
  }
}


resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "main-vpc"
    Environment = "dev"
    CostCenter  = "react-admin"
  }
}


resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "main-subnet"
    Environment = "dev"
    CostCenter  = "react-admin"
  }
}


resource "aws_security_group" "main_sg" {
  name        = "main-sg"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "main-sg"
    Environment = "dev"
    CostCenter  = "react-admin"
  }
}


resource "aws_instance" "web_server" {
  ami               = "ami-12345678"  
  instance_type     = "t3.micro"      
  subnet_id         = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.main_sg.id]

  tags = {
    Name        = "web-server"
    Environment = "dev"
    CostCenter  = "react-admin"
  }
}

resource "aws_instance" "cheap_server" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  
  spot_price = "0.003"       
  instance_market_options {
    market_type = "spot"
  }

  subnet_id               = aws_subnet.main_subnet.id
  vpc_security_group_ids  = [aws_security_group.main_sg.id]

  tags = {
    Name        = "spot-web-server"
    Environment = "dev"
    CostCenter  = "react-admin"
  }
}


resource "aws_s3_bucket" "app_bucket" {
  bucket = "react-admin-app-bucket"

  tags = {
    Name        = "react-admin-bucket"
    Environment = "dev"
    CostCenter  = "react-admin"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    id     = "cost-optimization"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 180
    }
  }
}

