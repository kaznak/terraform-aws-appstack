# -*- Mode: HCL; -*-

resource "aws_iam_role" "rds" {
  name               = "${local.default_name}.rds"
  path               = "/"
  description        = "RDS resource role for ${local.default_name}"
  assume_role_policy = data.aws_iam_policy_document.rds.json
}

data "aws_iam_policy_document" "rds" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "rds" {
  role       = aws_iam_role.rds.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
