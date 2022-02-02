resource "aws_iam_instance_profile" "server_profile" {
  role = aws_iam_role.server_role.name
}

resource "aws_iam_role" "server_role" {
  name_prefix = "skyspace-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ssm_role" {
  role       = aws_iam_role.server_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}