# -*- Mode: HCL; -*-

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name        = "alb-${replace(local.active_target_groups.service.arn_suffix, "/", "-")}-Unhealthy-Hosts"
  alarm_description = "Some instances are unhealthy."
  alarm_actions     = [aws_sns_topic.service_instance_trouble.arn]

  metric_name = "UnHealthyHostCount"
  namespace   = "AWS/ApplicationELB"
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = local.active_target_groups.service.arn_suffix
  }
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1

  tags = merge(local.common_tags,
    {
      "Name" = "${local.default_name}-Unhealthy-Hosts"
  })
}

resource "aws_cloudwatch_metric_alarm" "healthy_hosts" {
  alarm_name        = "alb-${replace(local.active_target_groups.service.arn_suffix, "/", "-")}-Healthy-Hosts"
  alarm_description = "Healthy hosts are too few."
  alarm_actions     = [aws_sns_topic.service_instance_trouble.arn]

  metric_name = "HealthyHostCount"
  namespace   = "AWS/ApplicationELB"
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = local.active_target_groups.service.arn_suffix
  }
  comparison_operator = "LessThanThreshold"
  statistic           = "Average"
  threshold           = 2
  evaluation_periods  = 1
  period              = 300

  tags = merge(local.common_tags,
    {
      "Name" = "${local.default_name}-Healthy-Hosts"
  })
}
