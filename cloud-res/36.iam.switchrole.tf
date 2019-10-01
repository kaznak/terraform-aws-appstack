# -*- Mode: HCL; -*-

resource "aws_iam_role" "cloudfront_operator" {
  name               = "CloudFrontOperatorAccessRole"
  description        = "CloudFront Operator Access Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(local.common_tags, {
    Name = "${local.default_name}-cloudfront-operator"
  })
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AssumeRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
	"arn:aws:iam::${local.cloudfrontoperator_aws_account_id[0]}:root",
	"arn:aws:iam::${local.cloudfrontoperator_aws_account_id[1]}:root",
      ]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

############################################################################
resource "aws_iam_role_policy_attachment" "cloudfront_operator" {
  role       = aws_iam_role.cloudfront_operator.name
  policy_arn = aws_iam_policy.cloudfront_operator.arn
}

resource "aws_iam_policy" "cloudfront_operator" {
  name        = "CloudFrontOperator${local.default_name}"
  path        = "/"
  description = "CloudFront Operator Role for ${local.default_name}"
  policy = data.aws_iam_policy_document.cloudfront_operator.json
}

data "aws_iam_policy_document" "cloudfront_operator" {
  statement {
    sid    = "CloudFrontOperator"
    effect = "Allow"
    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:ListInvalidations",
      "cloudfront:CreateInvalidation",
    ]
    resources = aws_cloudfront_distribution.www.*.arn
  }
}
