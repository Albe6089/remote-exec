variable "region" {
  type    = string
  default = "us-west-2"
}

variable "ubuntu_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "environment" {
  default = "dev"
}

variable "ingress_rules" {
  type = map(object({
    port        = number
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
  default = {
    "22" = {
      port        = 22
      description = "Port 22"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

}

variable "egress_rules" {
  type = map(object({
    port             = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
  default = {
    "0" = {
      port             = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

}