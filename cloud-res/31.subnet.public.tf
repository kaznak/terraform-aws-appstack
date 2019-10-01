# -*- Mode: HCL; -*-

resource "aws_subnet" "public" {
  count  = length(local.az_names)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(cidrsubnet(
    local.vpc_cidr_block,
    1, index(local.subnet_list, "public")),
  3, count.index)
  availability_zone = local.az_names[count.index]
  tags = merge(local.common_tags, {
    Name = "${local.default_name}-public-${local.az_names[count.index]}"
  })
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public.*.id
  tags = merge(local.common_tags, {
    Name = "${local.default_name}-public"
  })
}

resource "aws_network_acl_rule" "public-i_g_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "public-e_g_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
