data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_network_acls" "nacls" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_iam_role" "blue_team" {
  name = "BlueTeamRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "blue_team_nacl" {
  name = "BlueTeamNaclPolicy"
  role = aws_iam_role.blue_team.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
          Effect = "Allow",
          Action = "ec2:DescribeNetworkAcls",
          Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkAclEntry",
          "ec2:ReplaceNetworkAclEntry",
          "ec2:DeleteNetworkAclEntry"
        ],
        Resource = [
          for nacl in data.aws_network_acls.nacls.ids :
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-acl/${nacl}"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "blue_team" {
  name = "BlueTeamInstanceProfile"
  role = aws_iam_role.blue_team.name
}
