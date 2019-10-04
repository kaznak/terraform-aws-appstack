# -*- Mode: HCL; -*-

resource "aws_rds_cluster" "main" {
  cluster_identifier  = local.rds.name
  skip_final_snapshot = local.ephemeral
  availability_zones  = local.az_names

  db_subnet_group_name   = aws_db_subnet_group.main.id
  vpc_security_group_ids = [aws_security_group.private.id]

  engine                          = local.rds.engine.name
  engine_mode                     = "provisioned"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.id

  master_username = local.rds.username
  master_password = local.rds.password
  database_name   = local.rds.dbname

  backup_retention_period      = local.rds.backup.retention_period
  preferred_backup_window      = local.rds.backup.window
  preferred_maintenance_window = local.rds.maintenance_window

  tags = local.common_tags
}

resource "aws_rds_cluster_instance" "main" {
  count              = local.rds.count
  identifier         = "${local.rds.name}-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = local.rds.instance_class
  availability_zone  = local.az_names[count.index % length(local.az_names)]

  db_subnet_group_name = aws_db_subnet_group.main.name
  publicly_accessible  = false

  engine         = local.rds.engine.name
  engine_version = local.rds.engine.version

  monitoring_interval = local.rds.monitoring_interval
  monitoring_role_arn = aws_iam_role.rds.arn

  tags = local.common_tags
}
