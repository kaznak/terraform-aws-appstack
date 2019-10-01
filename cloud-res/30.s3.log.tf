# -*- Mode: HCL; -*-

resource "random_string" "s3_randomsig" {
  provider = random.r
  length   = 8
  upper    = false
  special  = false
}

resource "aws_s3_bucket" "log" {
  bucket = "${local.default_name}-log-${random_string.s3_randomsig.result}"
  acl    = "log-delivery-write"

  tags = merge(local.common_tags, {
    Name = "${local.default_name}-log"
  })
}

resource "aws_s3_bucket_policy" "log" {
  bucket = aws_s3_bucket.log.bucket
  policy = data.aws_iam_policy_document.log.json
}

data "aws_iam_policy_document" "log" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [local.elb_service_account]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.log.arn}/lb/*",
    ]
  }
}
