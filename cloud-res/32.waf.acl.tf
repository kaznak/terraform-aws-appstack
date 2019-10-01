# -*- Mode: HCL; -*-

resource "aws_waf_web_acl" "main" {
  name        = local.default_name
  metric_name = replace("${local.default_name}", "-", "")

  default_action {
    type = "ALLOW"
  }

  rules {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_waf_rule.main.id
    type     = "REGULAR"
  }
}

resource "aws_wafregional_web_acl" "main" {
  name        = "${local.default_name}-regional-${local.region}"
  metric_name = replace("${local.default_name}Regional${local.region}", "-", "")

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_wafregional_rule.main.id
    type     = "REGULAR"
  }
}
