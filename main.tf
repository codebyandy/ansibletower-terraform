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
resource "aws_key_pair" "sshkey" {
  key_name   = "andyjames-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPPi395XKUQEke2umV92KXPWz50GPVb6Y0lYpJ7dS1iXsQFQXymJRTWm53ldK7TvC7djJrnAti7PqSd1scjArBdxtkSGrtjKUPg8KIrYGcynCWIhZpgN8L0YWZqcixgYkU+KseHYQ62KwNJ+LvE3HdW8e57h/pr53W5GJQFERd5KB4gxkugJJuCEcx1L+W5m3ZRsECbCP+MUq251A/uQxqJdOmbRP+T0TAt7+SdGMjr0I8WAljR2XeVQYxL0A/n2LuIbAfrhhNaz/qK7jn+qA/dWY2haGR9nGpxI0pO5vGiC9TNAumfViJtAPjx63pSQcmKCh4p71paShDnFWzkJ0Z6WWlW2JqU+BrqcSkx184FAG8T1q4nm745D3qIQeMLfrR9LTgtDEnGSBAfU9VPfFsPlaEkGA6bGasVbYKCYAoslxKz//MxcZPTlSvGt7OFyS7JJVoq5+PNJOM0v2Hzr80Qba3N4UMvdkPXzjeqNHWXoc2q1SA5O4c57Dyz/Yh6jM= ajames@hashicorp.com"
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.centos.id
  instance_type   = var.size
  security_groups = [aws_security_group.allow_ssh.name, aws_security_group.allow_https.name]
  key_name        = aws_key_pair.sshkey.key_name

  tags = {
    Name = var.tag_name
    TTL = var.tag_ttl
    Owner = var.tag_owner
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y nano wget",
      "sudo wget https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-3.7.4-1.tar.gz",
      "sudo tar -zxf ansible-tower-setup-3.7.4-1.tar.gz",
      "sudo sed -i \"s/admin_password=''/admin_password='hashidemo'/g\" ansible-tower-setup-3.7.4-1/inventory",
      "sudo sed -i \"s/pg_password=''/pg_password='hashidemo'/g\" ansible-tower-setup-3.7.4-1/inventory",
      "sudo cd ansible-tower-setup-3.7.4-1 && ./setup.sh",
    ]
    connection {
    type     = "ssh"
    user     = "centos"
    private_key = var.ssh_key
    host     = aws_instance.web.public_ip
    }
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "Allow SSH"
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

  tags = {
    Name = "allow_tls"
    TTL = var.tag_ttl
    Owner = var.tag_owner
  }
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow https inbound traffic"

  ingress {
    description = "Allow https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_https"
    TTL = var.tag_ttl
    Owner = var.tag_owner
  }
}
