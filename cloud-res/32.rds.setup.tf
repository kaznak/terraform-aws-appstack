# -*- Mode: HCL; -*-

resource "aws_db_subnet_group" "main" {
  name       = local.rds.name
  subnet_ids = aws_subnet.private.*.id
  tags       = local.common_tags
}

resource "aws_rds_cluster_parameter_group" "main" {
  name   = local.rds.name
  family = local.rds.engine.family

  dynamic "parameter" {
    for_each = local.rds.rds_parameters
    content {
      name  = parameter.value["name"]
      value = parameter.value["value"]
    }
  }
}
