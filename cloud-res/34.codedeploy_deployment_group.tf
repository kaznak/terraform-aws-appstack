# -*- Mode: HCL; -*-

## Site: www #############################################################
resource "aws_codedeploy_app" "www" {
  name = "${local.default_name}-${replace(local.endpoints_www.prod,".","-")}"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "www" {
  count = length(values(local.endpoints_www))
  app_name              = aws_codedeploy_app.www.name
  deployment_group_name = "${local.default_name}-${replace(values(local.endpoints_www)[count.index],".","-")}"
  service_role_arn      = aws_iam_role.codedeploy.arn
  autoscaling_groups    = [local.active_autoscaling_groups.service.name]

  auto_rollback_configuration {
    enabled = keys(local.endpoints_www)[count.index] == "prod" ? true : false
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
