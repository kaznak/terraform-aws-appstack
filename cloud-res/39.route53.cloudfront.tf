# -*- Mode: HCL; -*-

# output "dns_record_main" {
#   value = zipmap(values(local.endpoints_www),
#       aws_cloudfront_distribution.www.*.domain_name)
# }

resource "aws_route53_record" "main" {
  provider = aws.control
  count    = length(local.endpoints_www)
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = values(local.endpoints_www)[count.index]
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.www.*.domain_name[count.index]
    zone_id                = aws_cloudfront_distribution.www.*.hosted_zone_id[count.index]
    evaluate_target_health = true
  }

  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -R ${values(local.endpoints_www)[count.index]}"
  }
}
