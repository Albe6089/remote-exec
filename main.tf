data "aws_caller_identity" "current" {}
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

// # creating a keypair
// resource "aws_key_pair" "my_key" {
//   key_name   = "my_key"
//   public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
// }

resource "tls_private_key" "default_rsa" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_ssm_parameter" "private_rsa_key" {
  name        = "bastion_private_rsa_key"
  description = "Bastion Host TLS Private Key"
  type        = "SecureString"
  value       = tls_private_key.default_rsa.private_key_pem
  depends_on  = [tls_private_key.default_rsa]
}

resource "aws_ssm_parameter" "public_rsa_key" {
  name        = "bastion_public_rsa_key"
  description = "Bastion Host TLS Public Key"
  type        = "SecureString"
  value       = tls_private_key.default_rsa.public_key_openssh
  depends_on  = [tls_private_key.default_rsa]
}

# creating a keypair
resource "aws_key_pair" "bastion_keypair" {
  key_name   = "bastion_keypair"
  public_key = tls_private_key.default_rsa.public_key_openssh
  depends_on  = [tls_private_key.default_rsa]

}

data "template_file" "user_data" {
  template = file("${path.root}/userdata.sh")

}


# creating a bastion-host
resource "aws_instance" "b-h" {
  ami                         = data.aws_ami.latest-ubuntu.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion_keypair.key_name
  instance_type               = var.ubuntu_instance_type
  iam_instance_profile        = aws_iam_instance_profile.default.name
  user_data                   = data.template_file.user_data.rendered
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  


  tags = {
    Name = "Bastion_Host"
  }
}

resource "null_resource" "test" {
  provisioner "local-exec" {
    command     = file("ssh-port-forward.sh")
    interpreter = ["bash", "-c"]
    environment = {
      INSTANCE_ID = aws_instance.b-h.id
      USERNAME    = "ubuntu"
      RANDOM_PORT = random_integer.ssh_port.result
    }
  }

  provisioner "remote-exec" {
    inline = ["echo hello world"]
    connection {
      host = "52.88.206.177"
      port = random_integer.ssh_port.result
      user = "ubuntu"
    }
  }
}

resource "random_integer" "ssh_port" {
  min = "10000"
  max = "60000"
}



# creating a bastion-host
// resource "aws_instance" "b-h" {
//   ami                    = data.aws_ami.latest-ubuntu.id
//   key_name               = aws_key_pair.bastion_keypair.key_name
//   instance_type          = var.ubuntu_instance_type
//   iam_instance_profile   = aws_iam_instance_profile.default.name
//   vpc_security_group_ids = [aws_security_group.bastion-sg.id]
//   user_data              = data.template_file.user_data.rendered

//   tags = {
//     Name = "Bastion_Host"
//   }
// }

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

// provisioner "local-exec" {
//     command    = "ansible-playbook user_add.yml -i inventory.ini --become"
//     on_failure = continue      
// }
// }


// resource "null_resource" "test" {
//   provisioner "local-exec" {
//     command     = file("ssh-port-forward.sh")
//     interpreter = ["bash", "-c"]
//     environment = {
//       INSTANCE_ID = "i-0d0efab728ecb4f0f"
//       USERNAME    = "ubuntu"
//       RANDOM_PORT = random_integer.ssh_port.result
//     }
//   }

//   provisioner "remote-exec" {
//     inline = ["echo hello world"]
//     connection {
//       host = "52.88.206.177"
//       port = random_integer.ssh_port.result
//       user = "ubuntu"
//       timeout ="1m"
//     }
//   }

//   depends_on = [aws_instance.b-h]

//   provisioner "local-exec" {
//     command    = "ansible-playbook user_add.yml -i inventory.ini --become"
//     on_failure = fail
//   }  
// }

// resource "random_integer" "ssh_port" {
//   min = "10000"
//   max = "60000"
// }