# -*- Mode: HCL; -*-

resource "aws_key_pair" "main" {
  key_name   = local.initial_key_pair.name
  public_key = file(local.initial_key_pair.path)
}
