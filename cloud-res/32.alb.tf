# -*- Mode: HCL; -*-

resource "aws_lb" "main" {
  depends_on = [
    aws_internet_gateway.main,
    aws_s3_bucket_policy.log
  ]
  name               = local.default_name
  load_balancer_type = "application"

  subnets         = aws_subnet.public.*.id
  security_groups = aws_security_group.public.*.id

  enable_deletion_protection = ! local.ephemeral

  access_logs {
    bucket  = aws_s3_bucket.log.bucket
    prefix  = "lb"
    enabled = true
  }
  tags = local.common_tags
}
