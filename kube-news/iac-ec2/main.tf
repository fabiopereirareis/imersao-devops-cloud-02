terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

   tags = {
    Name = "minha-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "minha-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "minha-internet-gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "minha-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "video-imersao-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZqRt1WJ55uOLFFFtv4hBsItlnWL/YMam+5sjPSn6gxXKl1PoKVIYHBRfcsD1JHHRaTnumX9d6XLjI8XhD2EOAsANWqdrNuEnj3wbz2Fu5C+WCgBddLErk2f6Qm1jFcC/JugD65HdJYfDG5sJMcBcw6k7t0S4Q53FXNDeFidjREKgK2iF46e06mPsD6ZPbJiW8+3cA3upK8ufd5aj6uv88iBCM7kR67R0WL/P3QrPWDEXM7U4ZIBYiiCk5HB54N08wqB9/TB6LVUY6Vyr9As/ymwihM8RzzyeROjiQbJjTkmkTF+7yz57jsPM0EEE27AknWvefrow4nAogMz/p1LkLczG7jSRWtkrljF7yfrtb3pCP2+GMO8INyGHKmOsjxS5Ibf5FH20AUwrfVYIH5dW/mHZT3+pokNcF+mMtRVxVZTMYyJxRbPW3usljSBm++Z9jaeVWb1Y6wxND06Qu+UI1cBG8BivJj0HHbkGO1vhr/yDWoIrJ+y4zHiagq3IPYYE= fabio@laptop-fabinho"
}

resource "aws_instance" "ec2" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet.id
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.security_group.id]

  tags = {
    Name = "minha-ec2"
  }
}

resource "aws_security_group" "security_group" {
  name        = "imersao-security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Liberacao de todas as portas"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "imersao-security_group"
  }
}

output "ip-ec2" {
  value = aws_instance.ec2.public_ip
}