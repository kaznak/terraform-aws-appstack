# -*- Mode: HCL; -*-

resource "aws_efs_file_system" "main" {
  tags = local.common_tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(aws_subnet.private)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.private.*.id[count.index]
  security_groups = [aws_security_group.private.id]
}
