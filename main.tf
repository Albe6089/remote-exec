# using a default vpc
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# using a data resource to lookup the latest ubuntu ami
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

# creating a keypair
resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

# creating a bastion-host
resource "aws_instance" "b-h" {
  ami                    = data.aws_ami.latest-ubuntu.id
  key_name               = aws_key_pair.my_key.key_name
  instance_type          = var.ubuntu_instance_type
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]

  tags = {
    Name = "Bastion_Host"
  }
}

# resource implements the standard resource lifecycle but takes no further action
resource "null_resource" "connect" {

  connection {
    type        = "ssh"
    port        = 22
    host        = aws_instance.b-h.public_ip
    private_key = file(pathexpand("~/.ssh/id_rsa"))
    user        = "ubuntu"
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update"
    ]
  }

  depends_on = [aws_instance.b-h]

}