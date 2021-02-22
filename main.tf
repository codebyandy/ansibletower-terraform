provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.centos.id
  instance_type = var.size

  tags = {
    Name = var.tag_name
    TTL = var.tag_ttl
    Owner = var.tag_owner
  }
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  vpc      = true
}
