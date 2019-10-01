# -*- Mode: HCL; -*-

resource "aws_subnet" "private" {
  count  = length(local.az_names)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(cidrsubnet(
    local.vpc_cidr_block,
    1, index(local.subnet_list, "private")),
  3, count.index)
  availability_zone = local.az_names[count.index]
  tags = merge(local.common_tags, {
    Name = "${local.default_name}-private-${local.az_names[count.index]}"
  })
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private.*.id
  tags = merge(local.common_tags, {
    Name = "${local.default_name}-private"
  })
}

############################################################################
# Allow
resource "aws_network_acl_rule" "private-i_x_all" {
  count          = length(local.allow_blocks)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100 + count.index
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = local.allow_blocks[count.index]
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private-e_x_all" {
  count          = length(local.allow_blocks)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100 + count.index
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = local.allow_blocks[count.index]
  from_port      = 0
  to_port        = 0
}

############################################################################
# Egress Global
resource "aws_network_acl_rule" "private-i_g_tcpephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 900
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = local.ephemeral_port_range[0]
  to_port        = local.ephemeral_port_range[1]
}

resource "aws_network_acl_rule" "private-i_g_udpephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 901
  egress         = false
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = local.ephemeral_port_range[0]
  to_port        = local.ephemeral_port_range[1]
}

resource "aws_network_acl_rule" "private-e_g_all" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 900
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
