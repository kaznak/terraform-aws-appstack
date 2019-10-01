# -*- Mode: HCL; -*-

locals {
  validation_name  = aws_acm_certificate.www_ap-northeast-1.*.domain_validation_options.0.resource_record_name
  validation_type  = aws_acm_certificate.www_ap-northeast-1.*.domain_validation_options.0.resource_record_type
  validation_value = aws_acm_certificate.www_ap-northeast-1.*.domain_validation_options.0.resource_record_value
}

resource "aws_route53_record" "www_acm_validation" {
  depends_on = [
    aws_acm_certificate.www_ap-northeast-1,
    aws_acm_certificate.www_us-east-1,
  ]
  provider = aws.control
  count    = length(local.endpoints_www)

  zone_id = data.aws_route53_zone.main.zone_id

  name    = local.validation_name[count.index]
  type    = local.validation_type[count.index]
  records = [local.validation_value[count.index]]
  ttl     = 60
}

# output "www_acm_validation" {
#   value = zipmap(
#     local.validation_name,
#     local.validation_value
#     )
# }
