# -*- Mode: HCL; -*-

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.default_name}-ec2"
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role" "ec2" {
  name               = "${local.default_name}-ec2"
  path               = "/"
  description        = "EC2 resource role for ${local.default_name}"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}

data "aws_iam_policy_document" "ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
