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

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    // original value "sigstore",
    "sts.amazonaws.com", // Used by aws-actions/configure-aws-credentials
  ]
  thumbprint_list = [
    // original value "a031c46782e6e6c662c2c87c76da9aa62ccabd8e",
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]
}

resource "aws_iam_role" "github_Albe6089" {
  name = "GitHubAlbe6089"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:aud" :  ["sts.amazonaws.com" ],
          "token.actions.githubusercontent.com:sub" : "repo:Albe6089/*"
        }
      }
    }]
  })
}
