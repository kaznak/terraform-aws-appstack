# -*- Mode: HCL; -*-

data "aws_elb_service_account" "main" {}
data "aws_availability_zones" "main" {}

locals {
  ## Names #################################################################
  default_name = "appstack"
  region       = "ap-northeast-1"
  # !NOTICE! ephemeral flag controles destroyable switches
  ephemeral    = false

  ## Network ###############################################################
  subnet_list          = ["private", "public"]
  publish_ports        = [80, 443]
  ephemeral_port_range = [32768, 60999]
  # https://en.wikipedia.org/wiki/Ephemeral_port

  vpc_cidr_block = "10.0.0.0/16"

  fullaccess_blocks = [
    "192.168.0.1/32", # example address
  ]

  allow_blocks = distinct(
    concat([local.vpc_cidr_block],
  local.fullaccess_blocks))

  ## EC2 Key pair ##########################################################
  initial_key_pair = {
    name = local.default_name
    path = "~/.ssh/id_rsa.pub"
  }

  ## EC2 AutoScaling : Maitenance ##########################################
  instances_maintenance = {
    name             = "${local.default_name}-maintenance"
    instance_type    = "t3.nano"
    user_data        = "32.user-data.maintenance.full.sh"
    key_name         = aws_key_pair.main.key_name
    ami              = concat(data.aws_ami_ids.maintenance.ids,
      data.aws_ami_ids.ubuntu.ids)[0]
    root_volume_size = 30
    max_count        = 1
    min_count        = 1
    health_check = {
      grace_period = 60
      type         = "EC2"
    }
  }

  ## EC2 AutoScaling : Service #############################################
  instances_service = {
    name             = "${local.default_name}-service"
    instance_type    = "t3.small"
    user_data        = "32.user-data.service.full.sh"
    key_name         = aws_key_pair.main.key_name
    ami              = concat(data.aws_ami_ids.service.ids,
      data.aws_ami_ids.ubuntu.ids)[0]
    root_volume_size = 30
    max_count        = 10
    min_count        = 2
    health_check = {
      grace_period = 60
      type         = "EC2"
    }
  }

  ## ALB ###################################################################
  active_target_groups = {
    service = aws_lb_target_group.service-blue
    # service = aws_lb_target_group.service-green
  }
  alb = {
    health_check = {
      protocol            = "HTTP"
      path                = "/"
      healthy_threshold   = 5
      unhealthy_threshold = 2
    }
  }
  listener_certs = aws_acm_certificate.www_ap-northeast-1.*.arn // back reference

  ## RDS ###################################################################
  rds = {
    count          = 2
    name           = local.default_name
    dbname         = "main"
    username       = random_string.username.result
    password       = random_string.password.result
    instance_class = "db.t2.small"
    engine = {
      name    = "aurora-mysql"
      version = "5.7.12"
      family  = "aurora-mysql5.7"
    }
    rds_parameters = [{
      name  = "time_zone"
      value = "asia/tokyo"
      }, {
      name  = "character_set_client"
      value = "utf8mb4"
      }, {
      name  = "character_set_connection"
      value = "utf8mb4"
      }, {
      name  = "character_set_database"
      value = "utf8mb4"
      }, {
      name  = "character_set_filesystem"
      value = "utf8mb4"
      }, {
      name  = "character_set_results"
      value = "utf8mb4"
      }, {
      name  = "character_set_server"
      value = "utf8mb4"
    }]
    backup = {
      retention_period = 14
      window           = "19:00-19:30"
    }
    maintenance_window  = "sun:20:00-sun:20:30"
    monitoring_interval = 60
  }

  ## Route53 ###############################################################
  domain = "example.com"

  endpoints_www = {
    prod = "www.${local.domain}"
    stg  = "stg-www.${local.domain}"
  }
  # !CAUTION! lots of part of these scripts assume the endpoints has only 2 name. be careful when change this.

  ## CodeDeploy ############################################################
  app_name = local.default_name
  active_autoscaling_groups = {
    service = aws_autoscaling_group.service-blue
    # service = aws_autoscaling_group.service-green
  }

  ## Misc ##################################################################
  az_names            = data.aws_availability_zones.main.names
  elb_service_account = data.aws_elb_service_account.main.arn
  main_aws_account_ids = ["000000000000"]
  cloudfrontoperator_aws_account_id = concat(local.main_aws_account_ids, 
    [ 
      "111111111111",
    ])
  # !CAUTION! rewrite 36.iam.switchrole.tf when change cloudfrontoperator_aws_account_id.

  common_tags = {
    Name      = local.default_name
    Devphase  = "test"
    Terraform = "true"
  }

  maintenance_domain = "example.com"
}

data "aws_route53_zone" "main" {
  provider = aws.control
  name     = local.domain
}

data "aws_route53_zone" "maintenance" {
  provider = aws.control
  name     = local.maintenance_domain
}
