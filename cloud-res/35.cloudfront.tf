# -*- Mode: HCL; -*-

## Site: www #############################################################
resource "aws_cloudfront_distribution" "www" {
  count   = length(local.endpoints_www)
  enabled = true
  aliases = [values(local.endpoints_www)[count.index]]

  web_acl_id = keys(local.endpoints_www)[count.index] == "prod" ? aws_waf_web_acl.www_prod.id : aws_waf_web_acl.www_stg.id

  viewer_certificate {
    # cloudfront_default_certificate = true
    acm_certificate_arn = aws_acm_certificate.www_us-east-1.*.arn[count.index]
    ssl_support_method  = "sni-only"
  }

  logging_config {
    bucket          = "${aws_s3_bucket.log.bucket_domain_name}"
    prefix          = "cloudfront/${values(local.endpoints_www)[count.index]}"
    include_cookies = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.default_name}-${values(local.endpoints_www)[count.index]}"
  })

  ##########################################################################
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    origin_id   = "main"
    domain_name = aws_lb.main.dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      # origin_protocol_policy = "http-only"
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    max_ttl     = keys(local.endpoints_www)[count.index] == "prod" ? 2419200 : 0
    default_ttl = keys(local.endpoints_www)[count.index] == "prod" ? 1209600 : 0
    min_ttl     = 0

    target_origin_id = "main"

    forwarded_values {
      cookies {
        forward = "all"
      }
      headers      = ["Host","User-agent"]
      query_string = true
      # query_string_cache_keys = { }
    }

    viewer_protocol_policy = "redirect-to-https"
    # viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern    = "wp-admin/*"
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    max_ttl     = 0
    default_ttl = 0
    min_ttl     = 0

    target_origin_id = "main"

    forwarded_values {
      cookies {
        forward = "all"
      }
      headers      = ["*"]
      query_string = true
      # query_string_cache_keys = { }
    }

    viewer_protocol_policy = "redirect-to-https"
    # viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern    = "wp-json/*"
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    max_ttl     = 0
    default_ttl = 0
    min_ttl     = 0

    target_origin_id = "main"

    forwarded_values {
      cookies {
        forward = "all"
      }
      headers      = ["*"]
      query_string = true
      # query_string_cache_keys = { }
    }

    viewer_protocol_policy = "redirect-to-https"
    # viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern    = "*.php"
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    max_ttl     = 0
    default_ttl = 0
    min_ttl     = 0

    target_origin_id = "main"

    forwarded_values {
      cookies {
        forward = "all"
      }
      headers      = ["*"]
      query_string = true
      # query_string_cache_keys = { }
    }

    viewer_protocol_policy = "redirect-to-https"
    # viewer_protocol_policy = "allow-all"
  }
}
