# -*- Mode: HCL; -*-

resource "aws_instance" "maintenance" {
  instance_type        = local.instances_maintenance.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  # user_data            = file(local.instances_maintenance.user_data)
  user_data = <<SCRIPT
#!/bin/bash
set -vxe
exec >> /var/log/user-data.log 2>&1
hostnamectl set-hostname maintenance.${local.default_name}
mount -a
SCRIPT

  vpc_security_group_ids = aws_security_group.private.*.id
  subnet_id              = aws_subnet.private[0].id

  associate_public_ip_address = true

  ami      = local.instances_maintenance.ami
  key_name = local.instances_maintenance.key_name

  root_block_device {
    volume_size = local.instances_maintenance.root_volume_size
  }

  tags = merge(local.common_tags, {
    "Name" = "${local.default_name}-maintenance"
  })
}

resource "aws_eip" "maintenance" {
  tags = merge(local.common_tags, {
    "Name" = "${local.default_name}-maintenance"
  })
}

resource "aws_eip_association" "maintenance" {
  instance_id   = aws_instance.maintenance.id
  allocation_id = aws_eip.maintenance.id
}

resource "aws_route53_record" "maintenance" {
  provider = aws.control

  zone_id = data.aws_route53_zone.maintenance.zone_id
  name    = "maintenance.${local.default_name}.${local.maintenance_domain}"
  type    = "A"
  ttl     = local.ephemeral ? "60" : "3600"
  records = [aws_eip.maintenance.public_ip]
}
