# -*- Mode: HCL; -*-

## Site: www ###############################################################
resource "aws_acm_certificate" "www_ap-northeast-1" {
  count             = length(values(local.endpoints_www))
  domain_name       = values(local.endpoints_www)[count.index]
  validation_method = "DNS"

  tags = merge(local.common_tags, {
    Name = "${local.default_name}_www_ap-northeast-1"
  })

  lifecycle {
    create_before_destroy = false
    prevent_destroy       = true
  }
}

resource "aws_acm_certificate_validation" "www_ap-northeast-1" {
  depends_on              = [aws_acm_certificate.www_ap-northeast-1]
  count                   = length(local.endpoints_www)
  certificate_arn         = aws_acm_certificate.www_ap-northeast-1.*.arn[count.index]
  validation_record_fqdns = [aws_route53_record.www_acm_validation.*.fqdn[count.index]]
}
