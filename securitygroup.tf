# Bastion-Host SG
// resource "aws_security_group" "bastion-sg" {
//   name_prefix = "bastion-sg"
//   description = "bastion security group"
//   // name   = "bastion-security-group-${terraform.workspace}"
//   vpc_id = data.aws_vpc.default.id

//   # SSH access from anywhere
//   dynamic "ingress" {

//     for_each = var.ingress_rules

//     # data for the block that was created dynamically 
//     content {
//       description = ingress.value.description
//       from_port   = ingress.value.port
//       to_port     = ingress.value.port
//       protocol    = ingress.value.protocol
//       cidr_blocks = ingress.value.cidr_blocks
//     }
//   }

//   dynamic "egress" {
//     for_each = var.egress_rules

//     # data for the block that was created dynamically 
//     content {
//       from_port        = egress.value.port
//       to_port          = egress.value.port
//       protocol         = egress.value.protocol
//       cidr_blocks      = egress.value.cidr_blocks
//       ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
//     }
//   }
//   tags = {
//     Name = "bastion-sg"
//   }

//   lifecycle {
//     create_before_destroy = true
//   }
// }