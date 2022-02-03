# using a default vpc
// data "aws_vpc" "default" {
//   default = true
// }

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
// resource "aws_key_pair" "my_key" {
//   key_name   = "my_key"
//   public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
// }

data "template_file" "user_data" {
  template = file("${path.root}/userdata.sh")

}
# creating a bastion-host
resource "aws_instance" "b-h" {
  ami = data.aws_ami.latest-ubuntu.id
  // key_name               = aws_key_pair.my_key.key_name
  instance_type          = var.ubuntu_instance_type
  iam_instance_profile   = aws_iam_instance_profile.server_profile.id
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  user_data              = data.template_file.user_data.rendered

  tags = {
    Name = "bastion"
  }
}

# resource implements the standard resource lifecycle but takes no further action
// resource "null_resource" "connect" {

//   triggers = {
//     always_run = timestamp()
//   }

//   connection {
//     type        = "ssh"
//     port        = 22
//     host        = aws_instance.b-h.public_ip
//     private_key = file(pathexpand("~/.ssh/id_rsa"))
//     user        = "ubuntu"
//     timeout     = "1m"
//   }

//   provisioner "remote-exec" {

//     inline = [
//       "sudo apt-get update -y",
//       "sudo apt install python3 -y",
//       "sudo apt install ansible -y"
//     ]
//   }

//   depends_on = [aws_instance.b-h]
//   provisioner "local-exec" {
//     command    = "ansible-playbook user_add.yml -i inventory.ini --become"
//     on_failure = continue
//   }
// }

// resource "null_resource" "remote_cmds" {

//   triggers = {
//     always_run = timestamp()
//   }

//   provisioner "local-exec" {
//     command    = "ansible-playbook user_add.yml -i inventory.ini --become"
//     on_failure = continue
//   }
// }

resource "null_resource" "remote_cmds" {
  // provisioner "file" {
  //   source      = "main.yml"
  //   destination = "/tmp/main.yml"
  // }
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command    = "ansible-playbook user_add.yml -i inventory.ini --become"
    on_failure = continue
  }
}