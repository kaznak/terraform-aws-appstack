# -*- Mode: HCL; -*-

resource "aws_iam_role" "codedeploy" {
  name               = "${local.default_name}-codedeploy"
  path               = "/"
  description        = "IAM Role for Codedeploy of ${local.default_name}"
  assume_role_policy = data.aws_iam_policy_document.codedeploy.json
}

data "aws_iam_policy_document" "codedeploy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = data.aws_iam_policy.service_role-aws_code_deploy_role.arn
}

data "aws_iam_policy" "service_role-aws_code_deploy_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}
