# -*- Mode: HCL; -*-

resource "aws_security_group" "public" {
  name   = "${local.default_name}-public"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = distinct(
      [aws_vpc.main.cidr_block]
    )
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = local.fullaccess_blocks
  }

  ################################################
  dynamic "ingress" {
    for_each = local.publish_ports
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ################################################
  tags = merge(local.common_tags, {
    Name = "${local.default_name}-public"
  })
}

resource "aws_security_group" "private" {
  name   = "${local.default_name}-private"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = distinct(
      [aws_vpc.main.cidr_block],
    )
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = local.fullaccess_blocks
  }

  ################################################
  tags = merge(local.common_tags, {
    Name = "${local.default_name}-private"
  })
}
