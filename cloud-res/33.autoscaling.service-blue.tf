# -*- Mode: HCL; -*-

resource "aws_lb_target_group" "service-blue" {
  name     = "${local.default_name}-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    protocol            = local.alb.health_check.protocol
    path                = local.alb.health_check.path
    healthy_threshold   = local.alb.health_check.healthy_threshold
    unhealthy_threshold = local.alb.health_check.unhealthy_threshold
  }
}

resource "aws_launch_configuration" "service-blue" {
  name                 = "${local.instances_service.name}-blue"
  instance_type        = local.instances_service.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  # user_data            = file(local.instances_service.user_data)
  user_data = <<SCRIPT
#!/bin/bash
set -vxe
exec >> /var/log/user-data.log 2>&1
hostnamectl set-hostname blue.service.${local.default_name}
mount -a
systemctl restart nginx
SCRIPT

  security_groups = aws_security_group.private.*.id
  associate_public_ip_address = true

  image_id = local.instances_service.ami
  key_name = local.instances_service.key_name

  root_block_device {
    volume_size = local.instances_service.root_volume_size
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_autoscaling_group" "service-blue" {
  availability_zones = local.az_names
  name = "${local.instances_service.name}-blue"
  max_size = local.instances_service.max_count
  min_size = local.instances_service.min_count
  health_check_grace_period = local.instances_service.health_check.grace_period
  health_check_type = local.instances_service.health_check.type
  force_delete = false
  launch_configuration = aws_launch_configuration.service-blue.name
  vpc_zone_identifier = aws_subnet.private.*.id
  target_group_arns = [aws_lb_target_group.service-blue.arn]
  lifecycle {
    create_before_destroy = true
  }
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
  tags = [{
    key = "Name"
    value = "${local.common_tags.Name}-service-blue"
    propagate_at_launch = true
    }, {
    key = "Devphase"
    value = local.common_tags.Devphase
    propagate_at_launch = true
    }, {
    key = "Terraform"
    value = local.common_tags.Terraform
    propagate_at_launch = true
  }]
}
