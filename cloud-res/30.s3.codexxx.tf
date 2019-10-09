# -*- Mode: HCL; -*-

resource "aws_s3_bucket" "codex" {
  bucket = "${local.default_name}-codex-${random_string.s3_randomsig.result}"
  acl    = "private"
  tags = merge(local.common_tags, {
    Name = "${local.default_name}-codex"
  })
}

resource "aws_iam_policy" "s3_codex" {
  name        = "${local.default_name}_s3access_codex"
  description = "access S3 codex"
  policy      = data.aws_iam_policy_document.codex.json
}

data "aws_iam_policy_document" "codex" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [
      aws_s3_bucket.codex.arn,
      "${aws_s3_bucket.codex.arn}/*",
    ]
  }
}
