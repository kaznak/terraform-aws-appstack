# -*- Mode: HCL; -*-

## Global ##################################################################
resource "aws_waf_rule" "prod" {
  depends_on = [
    aws_waf_ipset.fullaccess_blocks,
    aws_waf_byte_match_set.wp_sensitive,
  ]
  name        = local.default_name
  metric_name = replace("${local.default_name}Prod", "-", "")

  predicates {
    data_id = aws_waf_ipset.fullaccess_blocks.id
    negated = true
    type    = "IPMatch"
  }

  predicates {
    data_id = aws_waf_byte_match_set.wp_sensitive.id
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_waf_rule" "stg" {
  depends_on = [
    aws_waf_ipset.fullaccess_blocks,
    aws_waf_byte_match_set.wp_sensitive,
  ]
  name        = local.default_name
  metric_name = replace("${local.default_name}Stg", "-", "")

  predicates {
    data_id = aws_waf_ipset.fullaccess_blocks.id
    negated = true
    type    = "IPMatch"
  }
}

## Regional : ap-northeast-1  ##############################################
resource "aws_wafregional_rule" "main" {
  depends_on = [
    aws_wafregional_ipset.fullaccess_blocks,
    aws_wafregional_byte_match_set.wp_sensitive,
  ]
  name        = local.default_name
  metric_name = replace("${local.default_name}Regional${local.region}", "-", "")

  # !TODO! want to block Not FullAccess Blocks or Not CloudFront Blocks. This is incorrect
  predicate {
    data_id = aws_wafregional_ipset.fullaccess_blocks.id
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = aws_wafregional_byte_match_set.wp_sensitive.id
    negated = false
    type    = "ByteMatch"
  }
}
