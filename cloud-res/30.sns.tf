# -*- Mode: HCL; -*-

resource "aws_sns_topic" "service_instance_trouble" {
  name = "${local.default_name}-service_instance_trouble"
}
