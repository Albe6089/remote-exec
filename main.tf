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
  user_data              = <<EOF
#!/bin/bash -x
yum update -y && yum install ansible -y && mkdir /etc/ansible/roles/user_add/tasks -p

echo "# For when variables are being set from vars_prompt
- name: Generate users list
set_fact:
users:
- username: '{{ username }}'
comment: '{{ comment }}'
group: '{{ group }}'
addgroups: '{{ addgroups }}'
pwdhash: '{{ pwdhash }}'
issudo: '{{ issudo }}'
when: users is undefined

- name: Add user(s)
user:
name: '{{ item.username }}'
comment: '{{ item.comment }}'
group: '{{ item.group|default(omit) or omit }}'
groups: '{{ item.addgroups }}'
append: yes
state: present
password: '{{ item.pwdhash }}'
update_password: on_create
with_items: '{{ users }}'

- name: Add user(s) to sudoers
lineinfile:
dest: /etc/sudoers
regexp: '^{{ item.username }}\s'
line: '{{ item.username }} ALL=(ALL) ALL'
validate: '/usr/sbin/visudo -cf %s'
when: item.issudo | lower == 'y'
with_items: ' {{ users }}'" >> /etc/ansible/roles/user_add/tasks/main.yml
EOF

  tags = {
    Name = "Bastion_Host"
  }
}

# resource implements the standard resource lifecycle but takes no further action
resource "null_resource" "connect" {

  #Just a test
  triggers = {
    always_run = timestamp()
  }

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
      "sudo mkdir /etc/ansible/roles/user_add/tasks -p",
      "sudo mv /tmp/main.yml /etc/ansible/roles/user_add/tasks",
      "sudo apt-get update -y",
      "sudo apt install python3 -y",
      "sudo apt install ansible -y"
    ]
  }

  depends_on = [aws_instance.b-h]

  provisioner "file" {
    source      = "main.yml"
    destination = "/tmp/main.yml"
  }

  provisioner "local-exec" {
    command    = "echo public IP: ${aws_instance.b-h.public_ip}"
    on_failure = continue
  }

}

