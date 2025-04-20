# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" # Or your preferred version
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}


# Create a security group to allow HTTP traffic
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
# New ingress rule for SSH
  ingress {
    description      = "SSH from your IP"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "key-app-pair"

  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = <<-EOF
#!/bin/bash
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chmod 666 /var/run/docker.sock # Not ideal for production, but simplifies for this example
sudo mkdir -p /var/lib/expensetracker-data
sudo chmod 777 /var/lib/expensetracker-data
docker run -d -p 8080:8080 -v /var/lib/expensetracker-data:/flask-data emanshawky/expensetracker:latest
  EOF

  tags = {
    Name = "python-app-server"
  }
}

# Data source for Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Example filter, adjust as needed
  }
}

# Output the public IP address
output "public_ip" {
  value = aws_instance.web_server.public_ip
}