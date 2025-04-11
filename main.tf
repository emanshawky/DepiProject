provider "aws" {
  region     = "eu-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_key_pair" "deployer_new" {
  key_name   = "deployer-key1"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh_new" {
  name        = "allow_ssh1"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami             = "ami-05238ab1443fdf48f"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer_new.key_name
  security_groups = [aws_security_group.allow_ssh_new.name]

  tags = {
    Name = "TerraformEC2"
  }
}

resource "local_file" "ansible_inventory" {
  content  = templatefile("${path.module}/inventory.tpl", { instances = [aws_instance.web.public_ip] })
  filename = "${path.module}/inventory.ini"
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}