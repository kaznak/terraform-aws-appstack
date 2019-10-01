# -*- Mode: HCL; -*-

data "aws_ami_ids" "ubuntu" {
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-*-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami_ids" "maintenance" {
  owners = local.main_aws_account_ids

  filter {
    name   = "name"
    values = ["${local.default_name}.maintenance.*"]
  }
}

data "aws_ami_ids" "service" {
  owners = local.main_aws_account_ids

  filter {
    name   = "name"
    values = ["${local.default_name}.service.*"]
  }
}
