# -*- Mode: HCL; -*-

resource "aws_waf_ipset" "fullaccess_blocks" {
  name = "${local.default_name}-fullaccess_blocks"

  dynamic "ip_set_descriptors" {
    for_each = local.fullaccess_blocks
    content {
      type  = "IPV4"
      value = ip_set_descriptors.value
    }
  }
}

resource "aws_waf_byte_match_set" "wp_sensitive" {
  name = "${local.default_name}-wp_sensitive"

  byte_match_tuples {
    field_to_match {
      type = "URI"
    }
    positional_constraint = "STARTS_WITH"
    text_transformation   = "NONE"
    target_string         = "/wp-admin"
  }

  byte_match_tuples {
    field_to_match {
      type = "URI"
    }
    positional_constraint = "STARTS_WITH"
    text_transformation   = "NONE"
    target_string         = "/wp-config"
  }

  byte_match_tuples {
    field_to_match {
      type = "URI"
    }
    positional_constraint = "STARTS_WITH"
    text_transformation   = "NONE"
    target_string         = "/wp-json"
  }
}

resource "aws_wafregional_ipset" "fullaccess_blocks" {
  name = "${local.default_name}-fullaccess_blocks-regional-${local.region}"

  dynamic "ip_set_descriptor" {
    for_each = local.fullaccess_blocks
    content {
      type  = "IPV4"
      value = ip_set_descriptor.value
    }
  }
}

resource "aws_wafregional_byte_match_set" "wp_sensitive" {
  name = "${local.default_name}-wp_sensitive-regional-${local.region}"

  byte_match_tuples {
    field_to_match {
      type = "URI"
    }
    positional_constraint = "STARTS_WITH"
    text_transformation   = "NONE"
    target_string         = "/wp-admin"
  }

  byte_match_tuples {
    field_to_match {
      type = "URI"
    }
    positional_constraint = "STARTS_WITH"
    text_transformation   = "NONE"
    target_string         = "/wp-config"
  }
}
