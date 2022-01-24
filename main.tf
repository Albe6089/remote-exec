data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "b-h" {
  ami           = data.aws_ami.latest-ubuntu.id
  instance_type = var.ubuntu_instance_type

  tags = {
    Name = "Bastion-host"
  }
}