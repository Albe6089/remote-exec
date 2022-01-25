data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "b-h" {
  ami                    = data.aws_ami.latest-ubuntu.id
  instance_type          = var.ubuntu_instance_type
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]

  tags = {
    Name = "Bastion-host"
  }
}