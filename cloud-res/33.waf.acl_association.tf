# -*- Mode: HCL; -*-

resource "aws_wafregional_web_acl_association" "main" {
  # !TODO! The WAF Rule is not correct so disabling this association.
  count        = 0
  resource_arn = aws_lb.main.arn
  web_acl_id   = aws_wafregional_web_acl.main.id
}
