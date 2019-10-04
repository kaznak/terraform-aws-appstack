# -*- Mode: HCL; -*-

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "secret_key" {
  filename = "./id_rsa.AWS_SSH_PUBKEY"
  content  = tls_private_key.main.private_key_pem

  provisioner "local-exec" {
    command = "chmod 700 ./id_rsa.AWS_SSH_PUBKEY"
  }
}

resource "local_file" "public_key" {
  filename = "${local_file.secret_key.filename}.pub"
  content  = tls_private_key.main.public_key_openssh
}

resource "aws_key_pair" "main" {
  key_name   = local.default_name
  public_key = local_file.public_key.content
}
