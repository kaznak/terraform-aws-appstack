# -*- Mode: HCL; -*-

output "access_info" {
  value = [{
    type     = "db"
    endpoint = {
      write  = aws_rds_cluster.main.endpoint
      read   = aws_rds_cluster.main.reader_endpoint
    }
    username = aws_rds_cluster.main.master_username
    password = random_string.password.result
  },{
    type     = "ec2"
    endpoint = aws_route53_record.maintenance.name
    username = "ubnutu"
  }]
}

output "operator_role" {
  value = {
    cloudfront_invalidation = aws_iam_role.cloudfront_operator.arn
  }
}
