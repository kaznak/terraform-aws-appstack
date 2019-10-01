# -*- Mode: HCL; -*-

## Global ##################################################################
resource "aws_waf_web_acl" "www_prod" {
  name        = local.default_name
  metric_name = replace("${local.default_name}WwwProd", "-", "")

  default_action {
    type = "ALLOW"
  }

  rules {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_waf_rule.prod.id
    type     = "REGULAR"
  }
}

resource "aws_waf_web_acl" "www_stg" {
  name        = local.default_name
  metric_name = replace("${local.default_name}WwwStg", "-", "")

  default_action {
    type = "ALLOW"
  }

  rules {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_waf_rule.stg.id
    type     = "REGULAR"
  }
}

## Regional : ap-northeast-1  ##############################################
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
