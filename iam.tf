resource "aws_iam_instance_profile" "server_profile" {
  role = aws_iam_role.server_role.name
}

resource "aws_iam_role" "server_role" {
  name_prefix         = "skyspace-"
  assume_role_policy  = jsonencode({
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


// resource "aws_iam_instance_profile" "default" {
//   name = "ec2_host_instance_profile"
//   role = aws_iam_role.default.name
// }

// resource "aws_iam_role" "default" {
//   name = "ec2_host_iam_role"
//   path = "/"

//   assume_role_policy = data.aws_iam_policy_document.default.json
// }

// resource "aws_iam_role_policy" "main" {
//   name   = "ec2_iam_role_policy"
//   role   = aws_iam_role.default.id
//   policy = data.aws_iam_policy_document.main.json
// }

// data "aws_iam_policy_document" "default" {
//   statement {
//     sid = ""

//     actions = [
//       "sts:AssumeRole",
//     ]

//     principals {
//       type        = "Service"
//       identifiers = ["ec2.amazonaws.com"]
//     }

//     effect = "Allow"
//   }
// }

// data "aws_iam_policy_document" "main" {
//   statement {
//     effect = "Allow"

//     actions = [
//       "ssm:DescribeAssociation",
//       "ssm:GetDeployablePatchSnapshotForInstance",
//       "ssm:GetDocument",
//       "ssm:DescribeDocument",
//       "ssm:GetManifest",
//       "ssm:GetParameter",
//       "ssm:GetParameters",
//       "ssm:ListAssociations",
//       "ssm:ListInstanceAssociations",
//       "ssm:PutInventory",
//       "ssm:PutComplianceItems",
//       "ssm:PutConfigurePackageResult",
//       "ssm:UpdateAssociationStatus",
//       "ssm:UpdateInstanceAssociationStatus",
//       "ssm:UpdateInstanceInformation"
//     ]

//     resources = ["*"]
//   }

//   statement {
//     effect = "Allow"

//     actions = [
//       "ssmmessages:CreateControlChannel",
//       "ssmmessages:CreateDataChannel",
//       "ssmmessages:OpenControlChannel",
//       "ssmmessages:OpenDataChannel"
//     ]

//     resources = ["*"]
//   }

//   statement {
//     effect = "Allow"

//     actions = [
//       "ec2messages:AcknowledgeMessage",
//       "ec2messages:DeleteMessage",
//       "ec2messages:FailMessage",
//       "ec2messages:GetEndpoint",
//       "ec2messages:GetMessages",
//       "ec2messages:SendReply"
//     ]

//     resources = ["*"]
//   }

//   statement {
//     effect = "Allow"

//     actions = [
//       "s3:GetEncryptionConfiguration"
//     ]

//     resources = ["*"]
//   }
// }